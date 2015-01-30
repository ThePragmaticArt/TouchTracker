//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by TheGamingArt on 9/13/12.
//  Copyright (c) 2012 TheGamingArt. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Line; // added for gesture recognition

@interface TouchDrawView : UIView <UIGestureRecognizerDelegate>//making this a delegate permits this application to recognize two gestures at once
{
    NSMutableDictionary *linesInProcess; //created to draw lines still being drawn
    NSMutableArray *completeLines; //holds completed drawn lines
    
    UIPanGestureRecognizer *moveRecognizer;
    
    UISwipeGestureRecognizer *colorPaletteSwipeRecognizer;
    IBOutlet UIToolbar *paletteView;
    
    UIColor *color;
}

-(IBAction)changeColor:(UIBarButtonItem *)sender;

@property (nonatomic, weak) Line *selectedLine; //added to select line when screen is tapped


-(Line *)lineAtPoint:(CGPoint)p;

-(void)clearAll;
-(void)endTouches:(NSSet *)touches;

-(UIToolbar *)paletteView;


@end
