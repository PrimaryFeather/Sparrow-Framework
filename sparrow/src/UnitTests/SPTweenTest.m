//
//  SPTweenerTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.05.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPTween.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPTweenTest : SenTestCase 
{
  @private
    int mStartedCount;
    int mUpdatedCount;
    int mCompletedCount;
}

- (void)onTweenStarted:(SPEvent*)event;
- (void)onTweenUpdated:(SPEvent*)event;
- (void)onTweenCompleted:(SPEvent*)event;

@end

// -------------------------------------------------------------------------------------------------

@implementation SPTweenTest

- (void) setUp
{
    mStartedCount = mUpdatedCount = mCompletedCount = 0;
}

- (void)testBasicTween
{    
    float startX = 10.0f;
    float startY = 20.0f;
    float endX = 100.0f;
    float endY = 200.0f;
    float startAlpha = 1.0f;
    float endAlpha = 0.0f;
    float totalTime = 2.0f;
    
    SPQuad *quad = [SPQuad quadWithWidth:100 height:100];
    quad.x = startX;
    quad.y = startY;
    quad.alpha = startAlpha;
    
    SPTween *tween = [SPTween tweenWithTarget:quad time:totalTime transition:SP_TRANSITION_LINEAR];
    [tween addProperty:@"x" targetValue:endX];
    [tween addProperty:@"y" targetValue:endY];
    [tween addProperty:@"alpha" targetValue:endAlpha];    
    [tween addEventListener:@selector(onTweenStarted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween addEventListener:@selector(onTweenUpdated:) atObject:self forType:SP_EVENT_TYPE_TWEEN_UPDATED];    
    [tween addEventListener:@selector(onTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    
    tween.currentTime = 0;
    STAssertEqualsWithAccuracy(startX, quad.x, E, @"wrong x");
    STAssertEqualsWithAccuracy(startY, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha, quad.alpha, E, @"wrong alpha");        
    STAssertEquals(0, mStartedCount, @"start event dispatched too soon");
    
    tween.currentTime = totalTime/3.0f;   
    STAssertEqualsWithAccuracy(startX + (endX-startX)/3.0f, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(startY + (endY-startY)/3.0f, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha + (endAlpha-startAlpha)/3.0f, quad.alpha, E, @"wrong alpha");
    STAssertEquals(1, mStartedCount, @"missing start event");
    STAssertEquals(0, mUpdatedCount, @"updated event dispatched too soon");
    STAssertEquals(0, mCompletedCount, @"completed event dispatched too soon");
    
    tween.currentTime = 2*totalTime/3.0f;   
    STAssertEqualsWithAccuracy(startX + 2.0f*(endX-startX)/3.0f, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(startY + 2.0f*(endY-startY)/3.0f, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(startAlpha + 2.0f*(endAlpha-startAlpha)/3.0f, quad.alpha, E, @"wrong alpha");
    STAssertEquals(1, mStartedCount, @"too many start events dipatched");
    STAssertEquals(1, mUpdatedCount, @"missing update event");
    STAssertEquals(0, mCompletedCount, @"completed event dispatched too soon");
    
    tween.currentTime = totalTime;   
    STAssertEqualsWithAccuracy(endX, quad.x, E, @"wrong x: %f", quad.x);
    STAssertEqualsWithAccuracy(endY, quad.y, E, @"wrong y");
    STAssertEqualsWithAccuracy(endAlpha, quad.alpha, E, @"wrong alpha");
    STAssertEquals(1, mStartedCount, @"too many start events dispatched");
    STAssertEquals(1, mUpdatedCount, @"too many update events dispatched");
    STAssertEquals(1, mCompletedCount, @"missing completed event");
    
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_UPDATED];    
    [tween removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];    
}

- (void)onTweenStarted:(SPEvent*)event
{
    mStartedCount++;
}

- (void)onTweenUpdated:(SPEvent*)event
{
    mUpdatedCount++;
}

- (void)onTweenCompleted:(SPEvent*)event
{
    mCompletedCount++;
}

@end
