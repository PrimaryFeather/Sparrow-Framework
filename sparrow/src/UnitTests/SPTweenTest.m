//
//  SPTweenerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPTween.h"
#import "SPMacros.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPTweenTest : SenTestCase 
{
    int mStartedCount;
    int mUpdatedCount;
    int mCompletedCount;
    int mRepeatedCount;
}

@property (nonatomic, assign) int intProperty;

@end

// -------------------------------------------------------------------------------------------------

@implementation SPTweenTest

@synthesize intProperty = mIntProperty;

- (void) setUp
{
    mStartedCount = mUpdatedCount = mCompletedCount = mRepeatedCount = 0;
}

- (SPTween *)tweenWithTarget:(id)target time:(double)time
{
    SPTween *tween = [SPTween tweenWithTarget:target time:time];
    tween.onStart = ^{ mStartedCount++; };
    tween.onUpdate = ^{ mUpdatedCount++; };
    tween.onRepeat = ^{ mRepeatedCount++; };
    tween.onComplete = ^{ mCompletedCount++; };
    return tween;
}

- (void)testBasicTween
{    
    float startX = 10.0f;
    float startY = 20.0f;
    float endX = 100.0f;
    float endY = 200.0f;
    float startAlpha = 1.0f;
    float endAlpha = 0.0f;
    double totalTime = 2.0;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    quad.y = startY;
    quad.alpha = startAlpha;
    
    SPTween *tween = [self tweenWithTarget:quad time:totalTime];
    [tween animateProperty:@"x" targetValue:endX];
    [tween animateProperty:@"y" targetValue:endY];
    [tween animateProperty:@"alpha" targetValue:endAlpha];    
    
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x");
    STAssertEqualsWithAccuracy(startY, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha, quad.alpha, E, @"wrong alpha");        
    STAssertEquals(0, mStartedCount, @"start event dispatched too soon");
    
    [tween advanceTime: totalTime/3.0];   
    STAssertEqualsWithAccuracy(startX + (endX-startX)/3.0f, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(startY + (endY-startY)/3.0f, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha + (endAlpha-startAlpha)/3.0f, quad.alpha, E, @"wrong alpha");
    STAssertEqualsWithAccuracy(totalTime/3.0, tween.currentTime, E, @"wrong current time");
    STAssertEquals(1, mStartedCount, @"missing start event");
    STAssertEquals(1, mUpdatedCount, @"missing update event");
    STAssertEquals(0, mCompletedCount, @"completed event dispatched too soon");
    
    [tween advanceTime: totalTime/3.0];   
    STAssertEqualsWithAccuracy(startX + 2.0f*(endX-startX)/3.0f, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(startY + 2.0f*(endY-startY)/3.0f, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha + 2.0f*(endAlpha-startAlpha)/3.0f, quad.alpha, E, @"wrong alpha");
    STAssertEqualsWithAccuracy(2*totalTime/3.0, tween.currentTime, E, @"wrong current time");
    STAssertEquals(1, mStartedCount, @"too many start events dipatched");
    STAssertEquals(2, mUpdatedCount, @"missing update event");
    STAssertEquals(0, mCompletedCount, @"completed event dispatched too soon");
    
    [tween advanceTime: totalTime/3.0];
    STAssertEqualsWithAccuracy(endX, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(endY, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(endAlpha, quad.alpha, E, @"wrong alpha");
    STAssertEqualsWithAccuracy(totalTime, tween.currentTime, E, @"wrong current time");
    STAssertEquals(1, mStartedCount, @"too many start events dispatched");
    STAssertEquals(3, mUpdatedCount, @"missing update event");
    STAssertEquals(1, mCompletedCount, @"missing completed event");
}

- (void)testSequentialTweens
{
    float startPos = 0.0f;
    float targetPos = 50.0f;
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    
    // 2 tweens should move object up, then down
    SPTween *tween1 = [SPTween tweenWithTarget:quad time:1];
    [tween1 animateProperty:@"y" targetValue:targetPos];
    
    SPTween *tween2 = [SPTween tweenWithTarget:quad time:1];
    [tween2 animateProperty:@"y" targetValue:startPos];
    tween2.delay = 1;
    
    [tween1 advanceTime:1];
    STAssertEquals(targetPos, quad.y, @"wrong y value");
    
    [tween2 advanceTime:1];
    STAssertEquals(targetPos, quad.y, @"second tween changed y value on start");
                   
    [tween2 advanceTime:0.5];
    STAssertEqualsWithAccuracy((targetPos - startPos)/2.0f, quad.y, E, 
                 @"second tween moves object the wrong way");
    
    [tween2 advanceTime:0.5];
    STAssertEquals(startPos, quad.y, @"second tween moved to wrong y position");
}

- (void)testTweenFromZero
{
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.scaleX = 0.0f;
    SPTween *tween = [SPTween tweenWithTarget:quad time:1.0f];
    [tween animateProperty:@"scaleX" targetValue:1.0f];
    
    [tween advanceTime:0.0f];    
    STAssertEqualsWithAccuracy(0.0f, quad.width, E, @"wrong x value");
    
    [tween advanceTime:0.5f];
    STAssertEqualsWithAccuracy(50.0f, quad.width, E, @"wrong x value");
    
    [tween advanceTime:0.5f];
    STAssertEqualsWithAccuracy(100.0f, quad.width, E, @"wrong x value");
}

- (void)testRepeatingTween
{
    float startX = 100.0f;    
    float deltaX = 50.0f;
    float totalTime = 2.0f;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    
    SPTween *tween = [self tweenWithTarget:quad time:totalTime];
    [tween animateProperty:@"x" targetValue:startX + deltaX];
    tween.repeatCount = 5;
    
    [tween advanceTime:0.0];
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime / 2.0];
    STAssertEqualsWithAccuracy(startX + 0.5f * deltaX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime / 2.0];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(1, mRepeatedCount, @"repeated event not fired");
    
    [tween advanceTime:totalTime / 2.0];
    STAssertEqualsWithAccuracy(startX + 0.5f * deltaX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime / 2.0];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(2, mRepeatedCount, @"repeated event not fired");
    
    [tween advanceTime:totalTime * 2];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(4, mRepeatedCount, @"repeated event not fired the correct number of times");
    
    [tween advanceTime:totalTime];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(4, mRepeatedCount, @"repeated event not fired the correct number of times");
    STAssertEquals(1, mCompletedCount, @"completed event not fired");
}

- (void)testReversingTween
{
    float startX = 100.0f;    
    float deltaX = 50.0f;
    float totalTime = 2.0f;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    
    SPTween *tween = [self tweenWithTarget:quad time:totalTime];
    [tween animateProperty:@"x" targetValue:startX + deltaX];
    tween.repeatCount = 5;
    tween.reverse = YES;
    
    [tween advanceTime:0.0];
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime * 0.25];
    STAssertEqualsWithAccuracy(startX + 0.25f * deltaX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime * 0.5];
    STAssertEqualsWithAccuracy(startX + 0.75f * deltaX, quad.x, E, @"wrong x value");

    [tween advanceTime:totalTime * 0.25];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(1, mRepeatedCount, @"repeated event not fired");

    [tween advanceTime:totalTime * 0.25];
    STAssertEqualsWithAccuracy(startX + 0.75f * deltaX, quad.x, E, @"wrong x value");

    [tween advanceTime:totalTime * 0.5];
    STAssertEqualsWithAccuracy(startX + 0.25f * deltaX, quad.x, E, @"wrong x value");

    [tween advanceTime:totalTime * 0.25];
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x value");
    STAssertEquals(2, mRepeatedCount, @"repeated event not fired");
    
    [tween advanceTime:totalTime * 2];
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x value");
    STAssertEquals(4, mRepeatedCount, @"repeated event not fired the correct number of times");
    
    [tween advanceTime:totalTime];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(4, mRepeatedCount, @"repeated event not fired the correct number of times");
    STAssertEquals(1, mCompletedCount, @"completed event not fired the correct number of times");

    [tween advanceTime:totalTime];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    STAssertEquals(4, mRepeatedCount, @"repeated event not fired the correct number of times");
    STAssertEquals(1, mCompletedCount, @"completed event not fired the correct number of times");
}

- (void)testTweenWithChangingLoop
{
    float startX = 0.0f;
    float deltaX = 100.0f;
    float totalTime = 1.0f;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    
    SPTween *tween = [self tweenWithTarget:quad time:totalTime];
    [tween animateProperty:@"x" targetValue:startX + deltaX];
    
    [tween advanceTime:totalTime / 2.0f];
    STAssertEquals(0, mCompletedCount, @"completed event fired too soon");
    
    [tween advanceTime:totalTime / 2.0f];
    STAssertEquals(1, mCompletedCount, @"completed event not fired");
    STAssertEquals(0, mRepeatedCount,  @"repeated event fired too often");
    
    [tween advanceTime:totalTime * 2];
    STAssertEquals(1, mCompletedCount, @"completed event fired too often");
    
    tween.repeatCount = 100;
    
    [tween advanceTime:totalTime / 2.0f];
    STAssertEquals(1, mCompletedCount, @"completed event fired too often");
    
    [tween advanceTime:totalTime / 2.0f];
    STAssertEquals(1, mCompletedCount, @"completed event fired too often");
    STAssertEquals(1, mRepeatedCount,  @"repeated event not fired");
}

- (void)testRepeatDelay
{
    float startX = 0.0f;
    float deltaX = 100.0f;
    float totalTime = 1.0f;
    float delay = 0.5f;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    
    SPTween *tween = [self tweenWithTarget:quad time:totalTime];
    tween.repeatCount = 2;
    tween.repeatDelay = delay;
    [tween animateProperty:@"x" targetValue:startX + deltaX];

    [tween advanceTime:totalTime * 0.5];
    STAssertEqualsWithAccuracy(startX + 0.5f * deltaX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime * 0.5];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:delay * 0.5];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");

    [tween advanceTime:delay * 0.5];
    STAssertEqualsWithAccuracy(startX + deltaX, quad.x, E, @"wrong x value");
    
    [tween advanceTime:totalTime * 0.1f];
    STAssertEqualsWithAccuracy(startX + 0.1f * deltaX, quad.x, E, @"wrong x value");
}

- (void)testInfiniteRepeat
{
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    SPTween *tween = [self tweenWithTarget:quad time:1.0];
    tween.repeatCount = 0;
    [tween advanceTime:1000];
    
    STAssertEquals(1000, mRepeatedCount, @"wrong number of repetitions");
}

- (void)testUnsignedIntTween
{
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.color = 0;
    
    SPTween *tween = [SPTween tweenWithTarget:quad time:2.0];
    [tween animateProperty:@"color" targetValue:100];
    
    STAssertEquals((uint)0, quad.color, @"quad starts with wrong color");
    
    [tween advanceTime:1.0];
    STAssertEquals((uint)50, quad.color, @"wrong intermediate color");
    
    [tween advanceTime:1.0];
    STAssertEquals((uint)100, quad.color, @"wrong final color");
}

- (void)testSignedIntTween
{
    // try positive value
    SPTween *tween = [SPTween tweenWithTarget:self time:1.0];
    [tween animateProperty:@"intProperty" targetValue:100];
    [tween advanceTime:1.0];
    
    STAssertEquals(100, self.intProperty, @"tween didn't finish although time has passed");
    
    // and negative value
    self.intProperty = 0;
    tween = [SPTween tweenWithTarget:self time:1.0];
    [tween animateProperty:@"intProperty" targetValue:-100];
    [tween advanceTime:1.0];
    
    STAssertEquals(-100, self.intProperty, @"tween didn't finish although time has passed");
}

- (void)makeTweenWithTime:(double)time andAdvanceBy:(double)advanceTime
{
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    SPTween *tween = [self tweenWithTarget:quad time:time];
    [tween animateProperty:@"x" targetValue:100.0f];
    [tween advanceTime:advanceTime];
    
    STAssertEquals(1, mUpdatedCount, @"short tween did not call onUpdate");
    STAssertEquals(1, mStartedCount, @"short tween did not call onStarted");
    STAssertEquals(1, mCompletedCount, @"short tween did not call onCompleted");
}

- (void)testShortTween
{
    [self makeTweenWithTime:0.1f andAdvanceBy:0.1f];
}

- (void)testZeroTween
{
    [self makeTweenWithTime:0.0f andAdvanceBy:0.1f];
}

@end

#endif