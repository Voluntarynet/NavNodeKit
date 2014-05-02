//
//  NavNode.m
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import "NavNode.h"
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>

@implementation NavNode

- (id)init
{
    self = [super init];
    
    self.children = [NSMutableArray array];
    //self.actions  = [NSMutableArray array];
    //[self.actions addObject:@"testAction"];
    
    self.shouldSortChildren = YES;
    
    return self;
}

- (NSString *)nodeNote
{
    if (self.shouldUseCountForNodeNote && self.children.count)
    {
        return [NSString stringWithFormat:@"%i", (int)self.children.count];
    }
    
    return nil;
}

- (void)deepFetch
{
    [self fetch];
    
    for (id child in self.children)
    {
        if ([child respondsToSelector:@selector(fetch)])
        {
            //NSLog(@"child %@", child);
            [child deepFetch];
        }
    }
}

- (void)fetch
{
    
}

- (void)refresh
{
    [self fetch];
    [self postSelfChanged];
}

- (NSArray *)nodePathArray
{
    NSMutableArray *nodePathArray = [NSMutableArray array];
    NavNode *node = self;
    
    while (node)
    {
        [nodePathArray addObject:node];
        node = node.nodeParent;
    }
    
    [nodePathArray reverse];
    
    return nodePathArray;
}


- (NSUInteger)nodeDepth
{
    NSUInteger depth = 0;
    NavNode *nodeParent = self.nodeParent;
    
    while (nodeParent)
    {
        depth ++;
        nodeParent = nodeParent.nodeParent;
    }
    
    return depth;
}


- (void)setChildren:(NSMutableArray *)children
{
    _children = children;

    for (NavNode *child in self.children)
    {
        [child setNodeParent:self];
    }
}

- (id)addChild
{
    if (self.childClass)
    {
        id child = [[self.childClass alloc] init];
        [self addChild:child];
        [self postParentChanged];
        return child;
    }
    
    return nil;
}

- (void)add
{
    [self addChild];
}

- (void)addChild:(id)aChild
{
    if (![self.children containsObject:aChild])
    {
        [aChild setNodeParent:self];
        [self.children addObject:aChild];
        [self sortChildren];
       
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:aChild forKey:@"child"];
        
        NSNotification *note = [NSNotification notificationWithName:@"NavNodeAddedChild"
                                                             object:self
                                                           userInfo:info];
        
        [[NSNotificationCenter defaultCenter] postNotification:note];
        self.isDirty = YES;
    }
    else
    {
        [self sortChildren];
    }
}

- (void)removeChild:(id)aChild
{
    NSInteger i = [self.children indexOfObject:aChild];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:aChild forKey:@"child"];
    [info setObject:[NSNumber numberWithUnsignedInteger:i] forKey:@"index"];
    
    NSInteger nextIndex = i + 1;
    if (nextIndex < self.children.count)
    {
        id nextObject = [self.children objectAtIndex:nextIndex];
        [info setObject:nextObject forKey:@"nextObjectHint"];
    }
    
    [self.children removeObject:aChild];
    self.isDirty = YES;

    NSNotification *note = [NSNotification notificationWithName:@"NavNodeRemovedChild"
                                                         object:self
                                                       userInfo:info];
    
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)mergeWithChildren:(NSArray *)newChildren
{
    [self.children mergeWith:newChildren];
    [self setChildren:self.children];
}

- (void)sortChildren
{
    if (self.shouldSortChildren)
    {
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"nodeTitle"
                                                                 ascending:YES
                                                                  selector:@selector(caseInsensitiveCompare:)];

        //NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"nodeTitle" ascending:YES];
        [self.children sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    }
}

- (void)removeFromParent
{
    [self.nodeParent removeChild:self];
    [self.nodeParent postParentChanged];
}

- (NavNode *)childWithTitle:(NSString *)aTitle
{
    for (NavNode *child in self.children)
    {
        if ([[child nodeTitle] isEqualToString:aTitle])
        {
            return child;
        }
    }
    
    return nil;
}

- (NSArray *)nodeTitlePath:(NSArray *)pathComponents
{
    NavNode *node = self;
    NSMutableArray *nodes = [NSMutableArray array];
    
    for (NSString *title in pathComponents)
    {
        node = [node childWithTitle:title];
        
        if (node == nil)
        {
            return nil;
        }
        
        [nodes addObject:node];
    }
    
    return nodes;
}

- (NSString *)nodeTitle
{
    NSString *name = NSStringFromClass([self class]);
    NSString *prefix = @"BM";
    
    if ([name hasPrefix:prefix])
    {
        name = [name substringFromIndex:[prefix length]];
        name = [name lowercaseString];
    }
    
    return name;
}

- (NSString *)nodeSubtitle
{
    return nil;
}

// --- icon ----------------------

- (NSImage *)nodeIconForState:(NSString *)aState
{
    NSString *className = NSStringFromClass([self class]);
    NSString *iconName = [NSString stringWithFormat:@"%@_%@", className, aState];
    //NSLog(@"iconName: %@", iconName);
    //iconName = nil;
    return [NSImage imageNamed:iconName];
}

- (NSImage *)nodeActiveIcon
{
    return [self nodeIconForState:@"active"];
}

- (NSImage *)nodeInactiveIcon
{
    return [self nodeIconForState:@"inactive"];
}

- (NSImage *)nodeDisabledIcon
{
    return [self nodeIconForState:@"disabled"];
}

- (void)postParentChanged
{
    [self.nodeParent postSelfChanged];
}

- (void)postSelfChanged
{
    [self performSelector:@selector(justPostSelfChanged) withObject:nil afterDelay:0.0];
    [self justPostSelfChanged];
}

- (void)justPostSelfChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NavNodeChanged" object:self];
}


- (NSView *)nodeView
{
    if (!_nodeView)
    {
        id viewClass = self.class.firstViewClass;
        
        if (viewClass)
        {
            _nodeView = [(NSView *)[viewClass alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
            
            if ([_nodeView respondsToSelector:@selector(setNode:)])
            {
                [_nodeView performSelector:@selector(setNode:) withObject:self];
            }
        }
    }
    
    return _nodeView;
}

- (BOOL)canSearch
{
    return NO;
}

- (void)search:(NSString *)aString
{
    NSArray *parts = [aString componentsSeparatedByString:@" "];
    
    _searchResults = [NSMutableArray array];
    
    for (NavNode *child in self.children)
    {
        NSInteger remaining = parts.count;
        
        for (NSString *part in parts)
        {
            if (part.length == 0)
            {
                remaining --;
            }
            else if ([child nodeMatchesSearch:part])
            {
                remaining --;
            }
        }
        
        if (remaining == 0)
        {
            [_searchResults addObject:child];
        }
    }
}

- (BOOL)nodeMatchesSearch:(NSString *)aString
{
    if (self.nodeTitle && [self.nodeTitle containsCaseInsensitiveString:aString])
    {
        return YES;
    }
    
    if (self.nodeSubtitle && [self.nodeSubtitle containsCaseInsensitiveString:aString])
    {
        return YES;
    }
    
    return NO;
}

- (id)childWithAddress:(NSString *)address
{
    for (id child in self.children)
    {
        if ([child respondsToSelector:@selector(address)])
        {
            if([(NSString *)[child address] isEqualToString:address])
            {
                return child;
            }
        }
    }
    
    return nil;
}

// ----------------------

- (NSArray *)inlinedChildren
{
    NSMutableArray *inlinedChildren = [NSMutableArray array];
    
    for (NavNode *child in self.children)
    {
        [inlinedChildren addObject:child];
        [inlinedChildren addObjectsFromArray:child.children];
    }
    
    return inlinedChildren;
}

- (BOOL)nodeParentInlines
{
    if (self.nodeParent)
    {
        return self.nodeParent.shouldInlineChildren;
    }
    
    return NO;
}

- (BOOL)nodeShouldIndent
{
    NavNode *p = self.nodeParent;
    
    if (p)
    {
        p = p.nodeParent;
        
        if (p)
        {
            return p.shouldInlineChildren;
        }
    }
    
    return NO;
}

- (CGFloat)nodeSuggestedWidth
{
    return 300;
}

- (CGFloat)nodeSuggestedRowHeight
{
    if (self.shouldInlineChildren)
    {
        return 30;
    }
    
    return 60;
}

- (BOOL)isRead
{
    return YES;
}

// actions

- (NSArray *)actions
{
    return [self.modelActions arrayByAddingObjectsFromArray:self.uiActions];
}

- (NSArray *)modelActions
{
    return [NSMutableArray array];
}

- (NSArray *)uiActions
{
    return [NSMutableArray array];
}

- (NSString *)verifyActionMessage:(NSString *)aString
{
    return nil;
}

// default delete

- (void)delete
{
    [self removeFromParent];
}

- (BOOL)isDirtyRecursive
{
    if (self.isDirty)
    {
        return YES;
    }
    
    for (NavNode *child in self.children)
    {
        if (child.isDirtyRecursive)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)setCleanRecursive
{
    self.isDirty = NO;
    
    for (NavNode *child in self.children)
    {
        [child setCleanRecursive];
    }
}


@end
