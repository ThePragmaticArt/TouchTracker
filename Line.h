//
//  Line.h
//  TouchTracker
//
//  Created by TheGamingArt on 9/13/12.
//  Copyright (c) 2012 TheGamingArt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;
@property (nonatomic) UIColor *lineColor;

@end
