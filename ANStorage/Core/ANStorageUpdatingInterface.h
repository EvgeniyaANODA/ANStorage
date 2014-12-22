//
//  ANStorageUpdatingInterface.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@class ANStorageUpdate;

/**
 `DTStorageUpdating` protocol is used to transfer data storage updates.
 */

@protocol ANStorageUpdatingInterface <NSObject>

/**
 Transfers data storage updates. Controller, that implements this method, may react to received update by updating it's UI.
 
 @param update `DTStorageUpdate` instance, that incapsulates all changes, happened in data storage.
 */
- (void)storageDidPerformUpdate:(ANStorageUpdate *)update;

/**
 Method is called when UI needs to be fully updated for data storage changes.
 */
- (void)storageNeedsReload;

@end
