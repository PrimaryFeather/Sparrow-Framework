//
//  SPJugglerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.08.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPTween.h"
#import "SPJuggler.h"

// -------------------------------------------------------------------------------------------------

@interface SPJugglerTest : SenTestCase 
{
    SPJuggler *mJuggler;
    SPQuad *mQuad;    
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPJugglerTest

- (void)testModificationWhileInEvent
{    
    mJuggler = [[SPJuggler alloc] init];
    
    SPQuad *quad = [[SPQuad alloc] initWithWidth:100 height:100];    
    SPTween *tween = [SPTween tweenWithTarget:quad time:1.0f];
    [tween animateProperty:@"x" targetValue:20];    
    [tween addEventListener:@selector(onTweenCompleted:) atObject:self 
                    forType:SP_EVENT_TYPE_TWEEN_COMPLETED];    
    [mJuggler addObject:tween];
    
    [mJuggler advanceTime:0.3]; // -> 0.3 (start)
    [mJuggler advanceTime:0.3]; // -> 0.6 (update)

    STAssertNoThrow([mJuggler advanceTime:0.5], // -> 1.1 (complete) 
                    @"juggler could not cope with modification in tween callback");
}

- (void)onTweenCompleted:(SPEvent*)event
{
    SPTween *tween = [SPTween tweenWithTarget:mQuad time:0.5];    
    [mJuggler addObject:tween];
}

- (void)dealloc
{
    [mJuggler release];
    [mQuad release];
    [super dealloc];
}

@end