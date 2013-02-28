//
//  SPJugglerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.08.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPTween.h"
#import "SPJuggler.h"
#import "SPDelayedInvocation.h"

// -------------------------------------------------------------------------------------------------

@interface SPJugglerTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPJugglerTest

- (void)testModificationWhileInBlock
{
    __block BOOL startCallbackExecuted = NO;
    
    SPJuggler *juggler = [[SPJuggler alloc] init];
    
    SPQuad *quad = [[SPQuad alloc] initWithWidth:100 height:100];
    SPTween *tween = [SPTween tweenWithTarget:quad time:1.0f];
    tween.onComplete = ^
    {
        SPTween *tween = [SPTween tweenWithTarget:quad time:1.0f];
        tween.onStart = ^{ startCallbackExecuted = YES; };
        [juggler addObject:tween];
    };
    
    [juggler addObject:tween];
    
    [juggler advanceTime:0.4]; // -> 0.4 (start)
    [juggler advanceTime:0.4]; // -> 0.8 (update)
    
    STAssertNoThrow([juggler advanceTime:0.4], // -> 1.2 (complete)
                    @"juggler could not cope with modification in tween callback");
    
    [juggler advanceTime:0.4]; // 1.6 (start of new tween)
    STAssertTrue(startCallbackExecuted, @"juggler ignored modification made in callback");
}

- (void)testRemoveObjectsWithTarget
{
    SPJuggler *juggler = [SPJuggler juggler];
    
    SPQuad *quad1 = [SPQuad quadWithWidth:100 height:100];
    SPQuad *quad2 = [SPQuad quadWithWidth:200 height:200];
    
    SPTween *tween1 = [SPTween tweenWithTarget:quad1 time:1.0];    
    SPTween *tween2 = [SPTween tweenWithTarget:quad2 time:1.0];
    
    [tween1 animateProperty:@"rotation" targetValue:1.0f];
    [tween2 animateProperty:@"rotation" targetValue:1.0f];

    STAssertFalse([juggler containsObject:tween1], @"tween found in juggler too soon");
    STAssertFalse([juggler containsObject:tween2], @"tween found in juggler too soon");
    
    [juggler addObject:tween1];
    [juggler addObject:tween2];
    
    STAssertTrue([juggler containsObject:tween1], @"tween not found in juggler");
    STAssertTrue([juggler containsObject:tween2], @"tween not found in juggler");
    
    [juggler removeObjectsWithTarget:quad1];
    [juggler advanceTime:1.0];
    
    STAssertEquals(0.0f, quad1.rotation, @"removed tween was advanced");
    STAssertEquals(1.0f, quad2.rotation, @"wrong tween was removed");
}

- (void)testRemovalOfTween
{
    SPJuggler *juggler = [SPJuggler juggler];
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    SPTween *tween = [SPTween tweenWithTarget:quad time:1.0];
    
    [juggler addObject:tween];
    [juggler advanceTime:0.5];
    
    STAssertTrue([juggler containsObject:tween], @"tween was removed too soon");
    
    [juggler advanceTime:0.5];
    
    STAssertFalse([juggler containsObject:tween], @"tween was not removed in time");
}

- (void)testRemovalOfDelayedInvocation
{
    SPJuggler *juggler = [SPJuggler juggler];
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    id delayedInv = [juggler delayInvocationAtTarget:quad byTime:1.0];
    [delayedInv setX:100];
    
    [juggler addObject:delayedInv];
    [juggler advanceTime:0.5];
    
    STAssertTrue([juggler containsObject:delayedInv], @"delayed invocation was removed too soon");
    
    [juggler advanceTime:0.5];
    
    STAssertFalse([juggler containsObject:delayedInv], @"delayed invocation was not removed in time");
    STAssertEquals(100.0f, quad.x, @"delayed invocation not executed");
}

@end

#endif