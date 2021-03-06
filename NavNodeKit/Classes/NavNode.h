//
//  NavNode.h
//  Bitmarket
//
//  Created by Steve Dekorte on 1/31/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FoundationCategoriesKit/FoundationCategoriesKit.h>
#import "NavMirror.h"
#import "NavSlot.h"

#define NavNodeSelectedNotification      @"NavNodeSelected"
#define NavNodeChangedNotification       @"NavNodeChanged"
#define NavNodeAddedChildNotification    @"NavNodeAddedChild"
#define NavNodeRemovedChildNotification  @"NavNodeRemovedChild"


@class NavNode;

@protocol NodeViewProtocol <NSObject>
- (void)setNode:(id)aNode;
- (BOOL)handlesNodeActions; // optional
@end


@interface NavNode : NSObject

@property (strong, nonatomic) NavMirror *navMirror;

@property (assign, nonatomic) NavNode *nodeParent;
@property (strong, nonatomic) NSMutableArray *children;  // todo: nodeChildren
@property (strong, nonatomic) NSView *nodeView;
@property (strong, nonatomic) Class nodeViewClass;

@property (strong, nonatomic) NSNumber *nodeShouldSelectChildOnAdd;
@property (strong, nonatomic) NSNumber *nodeShouldSortChildren;
@property (strong, nonatomic) NSNumber *nodeShouldUseCountForNodeNote;
@property (strong, nonatomic) NSNumber *nodeIsDirty;

@property (strong, nonatomic) Class nodeChildClass;
@property (strong, nonatomic) NSString *nodeSortChildrenKey;
@property (strong, nonatomic) NSNumber *nodeSortAccending;  
@property (strong, nonatomic) NSNumber *nodeForceDisplayChildren;
@property (strong, nonatomic) NSNumber *nodeSuggestedWidth;
@property (strong, nonatomic) NSNumber *nodeMinWidth;

// --- last path ---

@property (strong, nonatomic) NSNumber *nodeDoesRememberChildPath;
@property (strong, nonatomic) NSArray *nodeRememberedChildTitlePath;

// --- search ---

//@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *nodeSearchResults;

// inlining

@property (assign, nonatomic) BOOL shouldInlineChildren;


- (NSString *)nodeTitle;
- (NSString *)nodeSubtitle;
- (NSString *)nodeSubtitleDetailed;
- (NSString *)nodeNote;

- (NSArray *)nodePathArray;
- (NSArray *)nodePathOfClass:(Class)aClass;
- (NSUInteger)nodeDepth;


// children

- (BOOL)addChild:(id)aChild;
- (void)add; 

- (void)removeChild:(id)aChild;
- (void)sortChildren;
- (void)sortChildrenWithKey:(NSString *)aKey;

- (void)removeFromParent;

- (void)mergeWithChildren:(NSArray *)newChildren;

// inlining

- (NSArray *)inlinedChildren;
- (BOOL)nodeParentInlines;
- (BOOL)nodeShouldIndent;
- (CGFloat)nodeSuggestedRowHeight;

- (NavNode *)childWithTitle:(NSString *)aTitle;
- (NSArray *)nodeTitlePath:(NSArray *)pathComponents;
- (NSArray *)nodeMaxTitlePath:(NSArray *)pathComponents;

- (NSImage *)nodeIconForState:(NSString *)aState;

- (BOOL)isRead;

// updating

@property (assign, nonatomic) BOOL deepRefreshes;
@property (assign, nonatomic) NSTimeInterval refreshInterval;
@property (nonatomic, retain) NSTimer *refreshTimer;

- (void)initCategory;

- (void)deepFetch;
- (void)fetch;
- (void)refresh;

- (void)postParentChanged;
- (void)postSelfChanged;
- (void)postParentChainChanged;
- (void)nodePostSelected;
- (void)justPostSelfChanged; // private but here for debugging

- (id)firstChildWithKindOfClass:(Class)aClass;

// --- search ---

- (BOOL)canSearch;
- (void)search:(NSString *)aString;
- (BOOL)nodeMatchesSearch:(NSString *)aString;
- (BOOL)nodeSearchOnReturn;

// actions

- (NSArray *)actions;
- (NSArray *)modelActions; // deprecated
- (NSArray *)uiActions; // deprecated

- (NSString *)verifyActionMessage:(NSString *)aString; // deprecating

- (id)addChild;

// dirty

- (BOOL)isDirtyRecursive;
- (void)setCleanRecursive;

// chain

- (BOOL)onFirstRespondingInParentChainSend:(SEL)aSelector;
- (id)firstInParentChainOfClass:(Class)aClass;
- (BOOL)inParentChainHasClass:(Class)aClass;
- (NSArray *)childrenWith:(SEL)selector equalTo:anObject;

- (void)updatedSlot:(NavSlot *)aNavSlot;

- (void)delete;

- (void)nodeWillSelect;
- (void)nodeDoubleClick;

@end
