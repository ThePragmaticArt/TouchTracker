//
//  TouchViewController.m
//  TouchTracker
//
//  Created by TheGamingArt on 9/13/12.
//  Copyright (c) 2012 TheGamingArt. All rights reserved.
//

#import "TouchViewController.h"
#import "TouchDrawView.h"

@implementation TouchViewController

-(void)loadView{
    [self setView:[[TouchDrawView alloc]initWithFrame:CGRectZero]];//initializes the view with an empty frame
}



@end
