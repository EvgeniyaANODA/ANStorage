//
//  ANSectionModel.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANSectionInterface.h"

@interface ANSectionModel : NSObject <ANSectionInterface>

@property (nonatomic, strong) NSMutableArray* objects;

- (id)supplementaryModelOfKind:(NSString*)kind;
- (void)setSupplementaryModel:(id)model forKind:(NSString *)kind;

@end
