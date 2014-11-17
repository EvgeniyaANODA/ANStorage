//
//  DTBaseStorage.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTStorageProtocol.h"

static NSString * const DTTableViewElementSectionHeader = @"DTTableViewElementSectionHeader";
static NSString * const DTTableViewElementSectionFooter = @"DTTableViewElementSectionFooter";

/**
 DTBaseStorage is a base class for storage classes.
 */

@interface DTBaseStorage : NSObject

/**
 *  For Debug use
 */
@property (nonatomic, strong) NSString* name;

/**
 Supplementary header kind, that is used for registration and mapping. For example, for UICollectionView this should be UICollectionElementKindSectionHeader.
 */
@property (nonatomic, strong) NSString * supplementaryHeaderKind;

/**
 Supplementary footer kind, that is used for registration and mapping. For example, for UICollectionView this should be UICollectionElementKindSectionFooter.
 */
@property (nonatomic, strong) NSString * supplementaryFooterKind;

/**
 Delegate property used to transfer current data storage changes.
 */
@property (nonatomic, weak) id <DTStorageUpdating> delegate;

@end
