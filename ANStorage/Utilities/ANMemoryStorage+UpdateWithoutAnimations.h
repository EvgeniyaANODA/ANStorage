//
//  ANMemoryStorage+UpdateWithoutAnimations.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANMemoryStorage.h"

@interface ANMemoryStorage (UpdateWithoutAnimations)

/**
 This method allows multiple simultaneous changes to memory storage without any notifications for delegate. You can think of this as a way of "manual" management for memory storage. Typical usage would be multiple insertions/deletions etc., if you don't need any animations. You can batch any changes in block, and call reloadData on your UI component after this method was call.
 
 @warning You must call reloadData after calling this method, or you will get NSInternalInconsistencyException runtime, thrown by either UITableView or UICollectionView.
 */
-(void)updateWithoutAnimations:(void(^)(void))block;

@end
