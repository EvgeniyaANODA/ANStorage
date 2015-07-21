//
//  ANStorageUpdate.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface ANStorageUpdate : NSObject

@property (atomic, assign) BOOL isProcessing;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *updatedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray* movedRowsIndexPaths;
- (BOOL)isEmpty;

@end
