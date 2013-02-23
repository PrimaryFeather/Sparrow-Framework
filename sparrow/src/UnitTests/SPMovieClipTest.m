//
//  SPMovieClipTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 03.06.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>

#import "SPMovieClip.h"
#import "SPTexture.h"

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPMovieClipTest : SenTestCase 
{
    int mCompletedCount;
}
@end

// -------------------------------------------------------------------------------------------------

@implementation SPMovieClipTest

- (void) setUp
{
    mCompletedCount = 0;
}

- (void)onMovieCompleted:(SPEvent*)event
{
    mCompletedCount++;
}

- (void)testFrameManipulation
{    
    float fps = 4.0;
    double frameDuration = 1.0 / fps;
    
    SPTexture *frame0 = [[SPTexture alloc] init];
    SPTexture *frame1 = [[SPTexture alloc] init];
    SPTexture *frame2 = [[SPTexture alloc] init];
    SPTexture *frame3 = [[SPTexture alloc] init];
    
    SPMovieClip *movie = [SPMovieClip movieWithFrame:frame0 fps:fps];    
    
    STAssertEqualsWithAccuracy(frame0.width, movie.width, E, @"wrong size");
    STAssertEqualsWithAccuracy(frame0.height, movie.height, E, @"wrong size");

    STAssertEquals(1, movie.numFrames, @"wrong number of frames");
    STAssertEquals(0, movie.currentFrame, @"wrong start value");
    STAssertEquals(YES, movie.loop, @"wrong default value");
    STAssertEquals(YES, movie.isPlaying, @"wrong default value");
    STAssertEqualsWithAccuracy(frameDuration, movie.totalTime, E, @"wrong totalTime");
    
    [movie pause];
    STAssertFalse(movie.isPlaying, @"property returns wrong value");
    
    [movie play];
    STAssertTrue(movie.isPlaying, @"property returns wrong value");
    
    movie.loop = NO;
    STAssertFalse(movie.loop, @"property returns wrong value");    
    
    [movie addFrameWithTexture:frame1];
    
    STAssertEquals(2, movie.numFrames, @"wrong number of frames");
    STAssertEqualsWithAccuracy(2 * frameDuration, movie.totalTime, E, @"wrong totalTime");
    
    STAssertEqualObjects(frame0, [movie textureAtIndex:0], @"wrong frame");
    STAssertEqualObjects(frame1, [movie textureAtIndex:1], @"wrong frame");
    
    STAssertEqualsWithAccuracy(frameDuration, [movie durationAtIndex:0] , E, @"wrong frame duration");
    STAssertEqualsWithAccuracy(frameDuration, [movie durationAtIndex:1] , E, @"wrong frame duration");
    
    STAssertNil([movie soundAtIndex:0], @"sound not nil");
    STAssertNil([movie soundAtIndex:1], @"sound not nil");
    
    [movie addFrameWithTexture:frame2 duration:0.5];
    STAssertEqualsWithAccuracy(0.5, [movie durationAtIndex:2], E, @"wrong frame duration");
    STAssertEqualsWithAccuracy(1.0, movie.totalTime, E, @"wrong totalTime");
    
    [movie addFrameWithTexture:frame3 atIndex:2]; // -> 0, 1, 3, 2
    STAssertEquals(4, movie.numFrames, @"wrong number of frames");
    STAssertEqualsWithAccuracy(1.0 + frameDuration, movie.totalTime, E, @"wrong totalTime");
    STAssertEqualObjects(frame1, [movie textureAtIndex:1], @"wrong frame");
    STAssertEqualObjects(frame3, [movie textureAtIndex:2], @"wrong frame");
    STAssertEqualObjects(frame2, [movie textureAtIndex:3], @"wrong frame");
    
    [movie removeFrameAtIndex:0]; // -> 1, 3, 2
    STAssertEquals(3, movie.numFrames, @"wrong number of frames");
    STAssertEqualObjects(frame1, [movie textureAtIndex:0], @"wrong frame");
    STAssertEqualsWithAccuracy(1.0, movie.totalTime, E, @"wrong totalTime");
    
    [movie removeFrameAtIndex:1]; // -> 1, 2
    STAssertEquals(2, movie.numFrames, @"wrong number of frames");
    STAssertEqualObjects(frame1, [movie textureAtIndex:0], @"wrong frame");
    STAssertEqualObjects(frame2, [movie textureAtIndex:1], @"wrong frame");
    STAssertEqualsWithAccuracy(0.75, movie.totalTime, E, @"wrong totalTime");
    
    [movie setTexture:frame3 atIndex:1];
    STAssertEqualObjects(frame3, [movie textureAtIndex:1], @"wrong frame");    
    
    [movie setDuration:0.75 atIndex:1];
    STAssertEqualsWithAccuracy(1.0, movie.totalTime, E, @"wrong totalTime");
    
    [movie addFrameWithTexture:frame3 atIndex:2];
    STAssertEquals(frame3, [movie textureAtIndex:2], @"wrong frame");
}

- (void)testAdvanceTime
{
    float fps = 4.0;
    double frameDuration = 1.0 / fps;
    
    SPTexture *frame0 = [[SPTexture alloc] init];
    SPTexture *frame1 = [[SPTexture alloc] init];
    SPTexture *frame2 = [[SPTexture alloc] init];
    SPTexture *frame3 = [[SPTexture alloc] init];
    
    SPMovieClip *movie = [SPMovieClip movieWithFrame:frame0 fps:fps];
    
    [movie addFrameWithTexture:frame1];
    [movie addFrameWithTexture:frame2 duration:0.5];
    [movie addFrameWithTexture:frame3];
    
    STAssertEquals(0, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration / 2.0];
    STAssertEquals(0, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration];
    STAssertEquals(1, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration];
    STAssertEquals(2, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration];
    STAssertEquals(2, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration];
    STAssertEquals(3, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration];
    STAssertEquals(0, movie.currentFrame, @"movie did not loop");
    
    movie.loop = NO;
    [movie advanceTime:movie.totalTime + frameDuration];
    STAssertEquals(3, movie.currentFrame, @"movie looped");
    STAssertFalse(movie.isPlaying, @"movie returned true for 'isPlaying' after reaching end");
    
    movie.currentFrame = 0;
    STAssertEquals(0, movie.currentFrame, @"wrong current frame");
    [movie advanceTime:frameDuration * 1.1];
    STAssertEquals(1, movie.currentFrame, @"wrong current frame");
    
    [movie stop];
    STAssertFalse(movie.isPlaying, @"movie returned true for 'isPlaying' after reaching end");
    STAssertEquals(0, movie.currentFrame, @"movie did not reset playhead on stop");
}

- (void)testChangeFps
{
    NSArray *frames = @[[[SPTexture alloc] init], [[SPTexture alloc] init],
                        [[SPTexture alloc] init]];
        
    SPMovieClip *movie = [SPMovieClip movieWithFrames:frames fps:4.0f];    
    STAssertEquals(4.0f, movie.fps, @"wrong fps");
    
    movie.fps = 3.0f;
    STAssertEquals(3.0f, movie.fps, @"wrong fps");    
    STAssertEqualsWithAccuracy(1.0 / 3.0, [movie durationAtIndex:0], E, @"wrong frame duration");
    STAssertEqualsWithAccuracy(1.0 / 3.0, [movie durationAtIndex:1], E, @"wrong frame duration");
    STAssertEqualsWithAccuracy(1.0 / 3.0, [movie durationAtIndex:2], E, @"wrong frame duration");
    
    [movie setDuration:1.0 atIndex:1];
    STAssertEqualsWithAccuracy(1.0, [movie durationAtIndex:1], E, @"wrong frame duration");
    
    movie.fps = 6.0f;
    STAssertEqualsWithAccuracy(0.5,       [movie durationAtIndex:1], E, @"wrong frame duration");
    STAssertEqualsWithAccuracy(1.0 / 6.0, [movie durationAtIndex:0], E, @"wrong frame duration");
    
    movie.fps = 0.0f;
    STAssertEqualsWithAccuracy(0.0f, movie.fps, E, @"wrong fps");
}

- (void)testCompletedEvent
{
    float fps = 4.0f;
    double frameDuration = 1.0 / fps;
    
    NSArray *frames = @[[[SPTexture alloc] init], [[SPTexture alloc] init],
                        [[SPTexture alloc] init], [[SPTexture alloc] init]];
    int numFrames = frames.count;
    
    SPMovieClip *movie = [SPMovieClip movieWithFrames:frames fps:fps];    
    [movie addEventListener:@selector(onMovieCompleted:) atObject:self 
                    forType:SP_EVENT_TYPE_COMPLETED];
    
    movie.loop = NO;
    
    [movie advanceTime:frameDuration];
    STAssertEquals(0, mCompletedCount, @"completed event fired too soon");
    [movie advanceTime:frameDuration];
    STAssertEquals(0, mCompletedCount, @"completed event fired too soon");
    [movie advanceTime:frameDuration];
    STAssertEquals(0, mCompletedCount, @"completed event fired too soon");
    [movie advanceTime:frameDuration];
    STAssertEquals(1, mCompletedCount, @"completed event not fired");    
    [movie advanceTime:numFrames * 2 * frameDuration];
    STAssertEquals(1, mCompletedCount, @"too many completed events fired");
    
    movie.loop = YES;
    
    [movie advanceTime:frameDuration];
    STAssertEquals(1, mCompletedCount, @"completed event fired too soon");
    [movie advanceTime:frameDuration];
    STAssertEquals(1, mCompletedCount, @"completed event fired too soon");
    [movie advanceTime:frameDuration];
    STAssertEquals(1, mCompletedCount, @"completed event fired too soon");
    [movie advanceTime:frameDuration];
    STAssertEquals(2, mCompletedCount, @"completed event not fired");    
    [movie advanceTime:numFrames * 2 * frameDuration];
    STAssertEquals(4, mCompletedCount, @"wrong number of events dispatched");
}

@end

#endif