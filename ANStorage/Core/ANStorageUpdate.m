//
//  ANStorageUpdate.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANStorageUpdate.h"

@implementation ANStorageUpdate

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:
@"\
Deleted Sections:   %@\n\
Inserted Sections:  %@\n\
Updated Sections:   %@\n\
Deleted Rows:       %@\n,\
Inserted rows:      %@\n\
Updated Rows:       %@\n",
self.deletedSectionIndexes.count   ? [self debugStringWithObject:self.deletedSectionIndexes]   : @"-->(none)",
self.insertedSectionIndexes.count  ? [self debugStringWithObject:self.insertedSectionIndexes]  : @"-->(none)",
self.updatedSectionIndexes.count   ? [self debugStringWithObject:self.updatedSectionIndexes]   : @"-->(none)",
self.deletedRowIndexPaths.count    ? [self debugStringWithObject:self.deletedRowIndexPaths]    : @"-->(none)",
self.insertedRowIndexPaths.count   ? [self debugStringWithObject:self.insertedRowIndexPaths]   : @"-->(none)",
self.updatedRowIndexPaths.count    ? [self debugStringWithObject:self.updatedRowIndexPaths]    : @"-->(none)"];
}

- (NSString*)debugStringWithObject:(id)obj
{
    return [NSString stringWithFormat:@"\n%@", obj];
}

- (NSMutableIndexSet *)deletedSectionIndexes
{
    if (!_deletedSectionIndexes)
    {
        _deletedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)insertedSectionIndexes
{
    if (!_insertedSectionIndexes)
    {
        _insertedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    return _insertedSectionIndexes;
}

- (NSMutableIndexSet *)updatedSectionIndexes
{
    if (!_updatedSectionIndexes)
    {
        _updatedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    return _updatedSectionIndexes;
}

- (NSMutableArray *)deletedRowIndexPaths
{
    if (!_deletedRowIndexPaths)
    {
        _deletedRowIndexPaths = [NSMutableArray array];
    }
    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths
{
    if (!_insertedRowIndexPaths)
    {
        _insertedRowIndexPaths = [NSMutableArray array];
    }
    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths
{
    if (!_updatedRowIndexPaths)
    {
        _updatedRowIndexPaths = [NSMutableArray array];
    }
    return _updatedRowIndexPaths;
}

- (NSMutableArray *)movedRowsIndexPaths
{
    if (!_movedRowsIndexPaths)
    {
        _movedRowsIndexPaths = [NSMutableArray array];
    }
    return _movedRowsIndexPaths;
}

- (BOOL)isEqual:(ANStorageUpdate *)update
{
    if (![update isKindOfClass:[ANStorageUpdate class]])
    {
        return NO;
    }
    if (![self.deletedSectionIndexes isEqualToIndexSet:update.deletedSectionIndexes])
    {
        return NO;
    }
    if (![self.insertedSectionIndexes isEqualToIndexSet:update.insertedSectionIndexes])
    {
        return NO;
    }
    if (![self.updatedSectionIndexes isEqualToIndexSet:update.updatedSectionIndexes])
    {
        return NO;
    }
    if (![self.deletedRowIndexPaths isEqualToArray:update.deletedRowIndexPaths])
    {
        return NO;
    }
    if (![self.insertedRowIndexPaths isEqualToArray:update.insertedRowIndexPaths])
    {
        return NO;
    }
    if (![self.updatedRowIndexPaths isEqualToArray:update.updatedRowIndexPaths])
    {
        return NO;
    }
    if (![self.movedRowsIndexPaths isEqualToArray:update.movedRowsIndexPaths])
    {
        return NO;
    }
    return YES;
}

- (BOOL)isEmpty
{
    return !(self.deletedSectionIndexes.count +
             self.insertedSectionIndexes.count +
             self.updatedSectionIndexes.count +
             self.deletedRowIndexPaths.count +
             self.insertedRowIndexPaths.count +
             self.updatedRowIndexPaths.count +
             self.movedRowsIndexPaths.count
             ) > 0;
}

@end
