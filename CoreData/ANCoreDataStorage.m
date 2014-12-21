//
//  ANCoreDataStorage.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANCoreDataStorage.h"
#import "ANStorageMovedIndexPath.h"

@interface ANCoreDataStorage ()

@end

@implementation ANCoreDataStorage

+ (instancetype)storageWithFetchResultsController:(NSFetchedResultsController *)controller
{
    ANCoreDataStorage * storage = [self new];

    storage.fetchedResultsController = controller;
    storage.fetchedResultsController.delegate = storage;

    return storage;
}

- (void)dealloc
{
    self.fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
}

- (NSArray *)sections
{
    return [self.fetchedResultsController sections];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

-(id)headerModelForSectionIndex:(NSInteger)index
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method");
    
    return [self supplementaryModelOfKind:self.supplementaryHeaderKind
                          forSectionIndex:index];
}

-(id)footerModelForSectionIndex:(NSInteger)index
{
    NSAssert(self.supplementaryFooterKind, @"supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method");
    
    return [self supplementaryModelOfKind:self.supplementaryFooterKind
                          forSectionIndex:index];
}

-(id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
{
    if ([kind isEqualToString:self.supplementaryHeaderKind])
    {
        id <NSFetchedResultsSectionInfo> section = [self sections][sectionNumber];
        return section.name;
    }
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)startUpdate
{
    self.currentUpdate = [ANStorageUpdate new];
}

- (void)finishUpdate
{
    if ([self.delegate respondsToSelector:@selector(storageDidPerformUpdate:)])
    {
        [self.delegate storageDidPerformUpdate:self.currentUpdate];
    }
    self.currentUpdate = nil;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self startUpdate];
}

/*
 Thanks to Michael Fey for NSFetchedResultsController updates done right!
 http://www.fruitstandsoftware.com/blog/2013/02/uitableview-and-nsfetchedresultscontroller-updates-done-right/
 */

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert)
    {
        if ([self.currentUpdate.insertedSectionIndexes containsIndex:newIndexPath.section])
        {
            // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
            return;
        }

        [self.currentUpdate.insertedRowIndexPaths addObject:newIndexPath];
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        if ([self.currentUpdate.deletedSectionIndexes containsIndex:indexPath.section])
        {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }

        [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
    }
    else if (type == NSFetchedResultsChangeMove)
    {

        /**
         *  IF you using TableMove cell method, you should nahdle any section - reliable parameters inside cell.
         * Moving cell don't cause cell reloading or tableViewCellForRowAtIndexPath
         */
        
        BOOL isNotInserted = ([self.currentUpdate.insertedSectionIndexes containsIndex:newIndexPath.section] == NO);
        BOOL isNotDeleted = ([self.currentUpdate.deletedSectionIndexes containsIndex:indexPath.section] == NO);
        BOOL isNotDeletedNewPath = ([self.currentUpdate.deletedSectionIndexes containsIndex:newIndexPath.section] == NO);
        
        BOOL isCorrectMove = isNotDeleted && isNotInserted && isNotDeletedNewPath;
            
        if (isCorrectMove && self.useMovingRows)
        {
            ANStorageMovedIndexPath* move = [ANStorageMovedIndexPath new];
            move.fromIndexPath = indexPath;
            move.toIndexPath = newIndexPath;
            [self.currentUpdate.movedRowsIndexPaths addObject:move];
        }
        else
        {
            if (isNotInserted)
            {
                [self.currentUpdate.insertedRowIndexPaths addObject:newIndexPath];
            }
            if (isNotDeleted)
            {
                [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
            }
        }

        
        //TODO: debug
//        if ([self.currentUpdate.insertedSectionIndexes containsIndex:newIndexPath.section] == NO)
//        {
//            [self.currentUpdate.insertedRowIndexPaths addObject:newIndexPath];
//        }
//        
//        if ([self.currentUpdate.deletedSectionIndexes containsIndex:indexPath.section] == NO)
//        {
//            [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
//        }
        
    }
    else if (type == NSFetchedResultsChangeUpdate)
    {
        [self.currentUpdate.updatedRowIndexPaths addObject:indexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.currentUpdate.insertedSectionIndexes addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.currentUpdate.deletedSectionIndexes addIndex:sectionIndex];
            break;
        default:; // Shouldn't have a default
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self finishUpdate];
}

@end
