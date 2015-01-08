//
//  ANModelTransfer.h
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@protocol ANModelTransfer

@required

/**
  This method will be called, when controller needs to display model on current cell
 
  @param model Model object to display on current cell
 
*/
- (void)updateWithModel:(id)model;

@optional

/**
 This method can be used to retrieve cell model from the cell. It is up to cell to decide, if it wants to store and get back the model. 
*/
- (id)model;

@end
