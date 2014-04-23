//
//  NavNode.h
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>

@class NavNode;

@protocol NodeViewProtocol <NSObject>
- (void)setNode:(id)aNode;
@end


@interface NavNode : NSObject

@property (assign, nonatomic) NavNode *nodeParent;
@property (strong, nonatomic) NSMutableArray *children;
//@property (strong, nonatomic) NSMutableArray *actions;
@property (strong, nonatomic) NSView *nodeView;
@property (assign, nonatomic) BOOL shouldSelectChildOnAdd;
@property (assign, nonatomic) BOOL shouldSortChildren;


- (NSString *)nodeTitle;
- (NSString *)nodeSubtitle;
- (NSString *)nodeNote;

- (NSUInteger)nodeDepth;

// children

- (void)addChild:(id)aChild;
- (void)removeChild:(id)aChild;
- (void)sortChildren;

// inlining

@property (assign, nonatomic) BOOL shouldInlineChildren;
- (NSArray *)inlinedChildren;
- (BOOL)nodeParentInlines;
- (BOOL)nodeShouldIndent;
- (CGFloat)nodeSuggestedRowHeight;

- (NavNode *)childWithTitle:(NSString *)aTitle;
- (NSArray *)nodeTitlePath:(NSArray *)pathComponents;

- (NSImage *)nodeIconForState:(NSString *)aState;

- (BOOL)isRead;

- (CGFloat)nodeSuggestedWidth;

- (void)deepFetch;
- (void)fetch;
- (void)refresh;

- (void)postParentChanged;
- (void)postSelfChanged;

- (id)childWithAddress:(NSString *)address; // hack - move to node subclass

// --- search ---

@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (BOOL)canSearch;
- (void)search:(NSString *)aString;
- (BOOL)nodeMatchesSearch:(NSString *)aString;

// actions

- (NSArray *)actions;
- (NSArray *)modelActions;
- (NSArray *)uiActions;

- (NSString *)verifyActionMessage:(NSString *)aString;

@end