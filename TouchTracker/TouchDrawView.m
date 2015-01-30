//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by TheGamingArt on 9/13/12.
//  Copyright (c) 2012 TheGamingArt. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"

@implementation TouchDrawView

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([[touch view].superview isKindOfClass:[UIToolbar class]]) {
        NSLog(@"Blocked GestureRecognizer from touch to view in class: %@", touch.view.superview.class);
        return FALSE;
    }
    
    NSLog(@"Did not block GestureRecognizer from touch to class: %@", touch.view.class);
    return TRUE;
}

-(IBAction)changeColor:(UIBarButtonItem *)sender{
    NSLog(@"Color: %@", [sender tintColor]);
    color = [sender tintColor];
    
    
}

-(UIToolbar *)paletteView{
    if (!paletteView) {
        [[NSBundle mainBundle] loadNibNamed:@"PaletteView" owner:self options:nil];
       // [paletteView bounds].origin.x
               
    }
    return paletteView;
}

-(Line *)lineAtPoint:(CGPoint)p{ //calculates if the tap was in a general vacinity of the tap
    //Find a line close to p
    
  
    
    for (Line *l in completeLines) {
        CGPoint start = [l begin];
        CGPoint end = [l end];
        
        
        

        //Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            
            if (hypot(x - p.x, y-p.y) < 20.0) {
                return l;
            }
        }
    }
    //If nothing is close enough to the tapped point, then we didn't select a line
    return nil;
}

-(void)tap:(UIGestureRecognizer *)gr{ // called when the user taps the screen through the UITapGestureRecognizer object declared in the initWithFrame method
    NSLog(@"Recognized tap");
    
    CGPoint point = [gr locationInView:self];
    [self setSelectedLine:[self lineAtPoint:point]];
    
    //If we just tapped, remove all lines in process so that a tap doesn't result in a new line
    [linesInProcess removeAllObjects];
    
    if ([self selectedLine]) {
        //We'll talk about this shortly
        [self becomeFirstResponder]; // canBecomeFirstResponder sets the ability for this view to become a first responder which is required for a UIMenuController view to exist ... the menu won't show if the methods in the menu items don't exist either
        //Grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        //Create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        [menu setMenuItems:[NSArray arrayWithObject:deleteItem]];
        //Tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES];
    }
    else{
        //Hide the menu if no line is selected
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
    
}

-(void)deleteLine:(id)sender{
    //Remove the selected line from the list of completeLines
    [completeLines removeObject:[self selectedLine]];
    //Redraw everything
    [self setNeedsDisplay];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        linesInProcess = [[NSMutableDictionary alloc]init];
        
        //Don't let the autocomplete fool you on the next line.
        //Make sure you are instantiating an NSMutableArray and not Dictionary
        completeLines = [[NSMutableArray alloc]init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setMultipleTouchEnabled:YES];
        
        
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]; // created a tap recognizer instance so when the user taps the screen, this object is sent first BEFORE the touchesBegan:withEvent method.
        [tapRecognizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:tapRecognizer]; //adds the recognizer
        
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]; // a longPress is sent after .5 seconds by default but this can be changed with the minimumPressDuration method
        [self addGestureRecognizer:pressRecognizer];
        
        moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        [moveRecognizer setDelegate:self];
        [moveRecognizer setCancelsTouchesInView:NO]; //moveRecognizer will eat all messages sent for creating the line if this is not set to no aka if set to yes (which it is by default for all UIGestureRecognizers) Views will not receive touches via the UIResponder methods
        [self addGestureRecognizer:moveRecognizer];
        
        colorPaletteSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(displayColorPalette:)];
        [colorPaletteSwipeRecognizer setCancelsTouchesInView:NO];
        [colorPaletteSwipeRecognizer setNumberOfTouchesRequired:2]; //needs to be 3
        [colorPaletteSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:colorPaletteSwipeRecognizer];
        
        if (!color) {
            color = [UIColor blackColor];
        }
        
        
        
        
    }
    return self;
}

-(void)displayColorPalette:(UIPanGestureRecognizer *)gr{
    [linesInProcess removeAllObjects];
    
    NSLog(@"3 Pan Gesture detected. Display Color Palette");
    //doesn't work
    //[UIToolbar setAnimationDelay:10.0f];
    
    if (!paletteView) {
        [self paletteView];
        
        
        CGPoint center;
        center.x = [super bounds].origin.x + [super bounds].size.width/2;
        center.y = [super bounds].origin.y + [super bounds].size.height - ([paletteView bounds].size.height /2);

        
        
        [self addSubview:paletteView];
        

        paletteView.viewForBaselineLayout.center = center;
        
       

        [paletteView setHidden:YES];
        
        
        }
    
    if([paletteView isHidden]){
         [paletteView setHidden:NO];
        [paletteView isAccessibilityElement];
        
        [UIView beginAnimations:@"appear" context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:paletteView cache:YES];
        [UIView setAnimationDelay:.2f];
        [UIView commitAnimations];

          [self setNeedsDisplay];

        
       
        return;
    }
    
    else if (![paletteView isHidden]){
        [paletteView setHidden:YES];
        
        
       
        [UIView beginAnimations:@"fade" context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:paletteView cache:YES];
        [UIView commitAnimations];

                
        [self setNeedsDisplay];
        return;
    }
   
    
   
    
    
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{ //This is why we made TouchDrawView a delegate of UIGesture.... so we can simultaneously send two touch gestures at once
    
    if (gestureRecognizer == moveRecognizer) {
        return YES;
    }
    return NO;
    
}


-(void)moveLine:(UIPanGestureRecognizer *)gr{
    if (![self selectedLine]) {
        return;
    }
    
    //When the pan recognizer changes its position...
    if ([gr state] == UIGestureRecognizerStateChanged) {
        //How far has the pan moved?
        CGPoint translation = [gr translationInView:self];
        
        //Add the translation to the current being and end points of the line
        CGPoint begin = [[self selectedLine]begin];
        CGPoint end = [[self selectedLine]end];
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        //Set the new beginning and end points of the line
        [[self selectedLine] setBegin:begin];
        [[self selectedLine] setEnd:end];
        
        //Redraw the screen
        [self setNeedsDisplay];
        [gr setTranslation:CGPointZero inView:self]; //Must be reset because the current translation is being added over and over again to the ORIGINAL end points rather the new points...
    }
}

-(void)longPress:(UIGestureRecognizer *)gr{ 
    if ([gr state] == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        [self setSelectedLine:[self lineAtPoint:point]];
        
        if ([self selectedLine]) {
            [linesInProcess removeAllObjects];
        }
        
    }
    else if ([gr state] == UIGestureRecognizerStateEnded){
        [self setSelectedLine:nil];
    }
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
       
    //Draw complete lines in black
    //[[UIColor color] set];
    for (Line *line in completeLines) {
        [[line lineColor] set];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    //Draw lines in process in red (Don't copy and paste the previous loop;
    //This one is way different
    [[UIColor redColor]set];
    for (NSValue *v in linesInProcess) {
        Line *line = [linesInProcess objectForKey:v];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    
    
    //If there is a selected line, draw it
    if ([self selectedLine]) {
        [[UIColor greenColor]set];
        CGContextMoveToPoint(context, [[self selectedLine] begin].x, [[self selectedLine] begin].y);
        CGContextAddLineToPoint(context, [[self selectedLine] end].x, [[self selectedLine] end].y);
        CGContextStrokePath(context);
    }

    
    }

-(void)clearAll{
    //Clear the collection
    [linesInProcess removeAllObjects];
    [completeLines removeAllObjects];
    
    //Redraw the display empty
    [self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {
        //Is this a double tap?
        if ([t tapCount] > 1) {
            [self clearAll];
            return;
        }
        
        //Use the touch object (packed in an NSValue) as the key
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        //Create a line for the value
        CGPoint loc = [t locationInView:self];
        Line *newLine =[[Line alloc]init];
        [newLine setBegin:loc];
        [newLine setEnd:loc];
        
       

        [newLine setLineColor:color];
        
        //put pair in dictionary
        [linesInProcess setObject:newLine forKey:key];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //Update linesInProcess with moved touches
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        //Find the line for this touch
        Line *line = [linesInProcess objectForKey:key];
        
        //Update the line
        CGPoint loc = [t locationInView:self];
        [line setEnd:loc];
    }
    //Redraw
    [self setNeedsDisplay];
}

-(void)endTouches:(NSSet *)touches{
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        //If this is a double tap, 'line' will be nil
        //so make sure not to add it to the array
        if (line) {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
        }
    }
    //Redraw
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self endTouches:touches];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{ //if an event interrupts on the screen
    [self endTouches:touches];
}


@end
