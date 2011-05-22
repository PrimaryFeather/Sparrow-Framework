//
//  SPEventDispatcherTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.04.09.
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
#import "SPSprite.h"
#import "SPEvent.h"

// -------------------------------------------------------------------------------------------------

@interface SPEventDispatcherTest : SenTestCase 
{
    int mTestCounter;
}

@end

// -------------------------------------------------------------------------------------------------

@implementation SPEventDispatcherTest

#define EVENT_TYPE @"EVENT_TYPE"

- (void)setUp
{
    mTestCounter = 0;
}

- (void)testAddAndRemoveEventListener
{
    SPEventDispatcher *dispatcher = [[SPEventDispatcher alloc] init];
    [dispatcher addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];    
    STAssertTrue([dispatcher hasEventListenerForType:EVENT_TYPE], @"missing event listener");

    [dispatcher removeEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];
    STAssertFalse([dispatcher hasEventListenerForType:EVENT_TYPE], @"remove failed");    
    
    [dispatcher release];
}

- (void)testRemoveAllEventListenersOfObject
{
    SPEventDispatcher *dispatcher = [[SPEventDispatcher alloc] init];
    [dispatcher addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];    
    STAssertTrue([dispatcher hasEventListenerForType:EVENT_TYPE], @"missing event listener");
    
    [dispatcher removeEventListenersAtObject:self forType:EVENT_TYPE];
    STAssertFalse([dispatcher hasEventListenerForType:EVENT_TYPE], @"remove failed");
    
    [dispatcher release];
}

- (void)testSimpleEvent
{
    SPEventDispatcher *dispatcher = [[SPEventDispatcher alloc] init];
    [dispatcher addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];    
    [dispatcher dispatchEvent:[SPEvent eventWithType:EVENT_TYPE]];    
    STAssertEquals(1, mTestCounter, @"event listener not called");    
    
    [dispatcher removeEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];    
    [dispatcher release];
}

- (void)testBubblingEvent
{
    SPSprite *sprite1 = [[SPSprite alloc] init];
    [sprite1 addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];
    
    SPSprite *sprite2 = [[SPSprite alloc] init];
    [sprite2 addEventListener:@selector(stopEvent:) atObject:self forType:EVENT_TYPE];
    
    SPSprite *sprite3 = [[SPSprite alloc] init];
    [sprite3 addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];
    
    SPSprite *sprite4 = [[SPSprite alloc] init];
    [sprite4 addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];
    
    [sprite1 addChild:sprite2];
    [sprite2 addChild:sprite3];
    [sprite3 addChild:sprite4];
    
    [sprite4 dispatchEvent:[SPEvent eventWithType:EVENT_TYPE]];
    
    STAssertEquals(1, mTestCounter, @"event bubbled, but should not have");
    mTestCounter = 0;
    
    [sprite4 dispatchEvent:[SPEvent eventWithType:EVENT_TYPE bubbles:YES]];
    STAssertEquals(2, mTestCounter, @"event bubbling incorrect");
    
    [sprite1 removeEventListenersAtObject:self forType:EVENT_TYPE];
    [sprite2 removeEventListenersAtObject:self forType:EVENT_TYPE];
    [sprite3 removeEventListenersAtObject:self forType:EVENT_TYPE];
    [sprite4 removeEventListenersAtObject:self forType:EVENT_TYPE];
    [sprite1 release];
    [sprite2 release];
    [sprite3 release];
    [sprite4 release];
}

- (void)testStopImmediatePropagation
{
    SPSprite *sprite = [[SPSprite alloc] init];
    [sprite addEventListener:@selector(onEvent:) atObject:self forType:EVENT_TYPE];
    [sprite addEventListener:@selector(onEvent2:) atObject:self forType:EVENT_TYPE];
    [sprite addEventListener:@selector(stopEventImmediately:) atObject:self forType:EVENT_TYPE];
    [sprite addEventListener:@selector(onEvent3:) atObject:self forType:EVENT_TYPE];
    [sprite dispatchEvent:[SPEvent eventWithType:EVENT_TYPE]];    
    
    STAssertEquals(2, mTestCounter, @"stopEventImmediately did not work correctly");
    
    [sprite removeEventListenersAtObject:self forType:EVENT_TYPE];
    [sprite release];    
}

- (void)onEvent:(SPEvent*)event
{
    mTestCounter++;
}

- (void)onEvent2:(SPEvent*)event
{
    mTestCounter *= 2;
}

- (void)onEvent3:(SPEvent*)event
{
    mTestCounter += 3;
}

- (void)stopEvent:(SPEvent*)event
{
    [event stopPropagation];
}

- (void)stopEventImmediately:(SPEvent*)event
{
    [event stopImmediatePropagation];
}

@end

#endif