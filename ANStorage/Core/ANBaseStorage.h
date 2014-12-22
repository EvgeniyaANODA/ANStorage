//
//  ANBaseStorage.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANStorageInterface.h"

static NSString * const ANTableViewElementSectionHeader = @"ANTableViewElementSectionHeader";
static NSString * const ANTableViewElementSectionFooter = @"ANTableViewElementSectionFooter";

@interface ANBaseStorage : NSObject

/**
 *  For Debug use
 */
@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString * supplementaryHeaderKind;
@property (nonatomic, strong) NSString * supplementaryFooterKind;
@property (nonatomic, weak) id <ANStorageUpdatingInterface> delegate;

@end
