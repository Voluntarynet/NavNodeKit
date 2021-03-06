//
//  NavActionSlot.h
//  NavNodeKit
//
//  Created by Steve Dekorte on 5/19/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "NavSlot.h"

@interface NavActionSlot : NavSlot

// isActive

- (void)setIsActive:(BOOL)aBool;
- (BOOL)isActive;

// verify message

- (void)setVerifyMessage:(NSString *)aString;
- (NSString *)verifyMessage;

// send

- (SEL)actionSelector;
- (void)sendAction;

@end
