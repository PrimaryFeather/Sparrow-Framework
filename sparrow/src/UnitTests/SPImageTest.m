//
//  untitled.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Availability.h>
#ifdef __IPHONE_3_0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPImage.h"
#import "SPPoint.h"

// -------------------------------------------------------------------------------------------------

@interface SPImageTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPImageTest

- (void)testInit
{
    SPImage *image = [[SPImage alloc] init];
    STAssertEqualObjects([SPPoint pointWithX:0 y:0], [image texCoordsOfVertex:0], @"wrong tex coords!");
    STAssertEqualObjects([SPPoint pointWithX:1 y:0], [image texCoordsOfVertex:1], @"wrong tex coords!");    
    STAssertEqualObjects([SPPoint pointWithX:1 y:1], [image texCoordsOfVertex:2], @"wrong tex coords!");    
    STAssertEqualObjects([SPPoint pointWithX:0 y:1], [image texCoordsOfVertex:3], @"wrong tex coords!");
    [image release];    
}

- (void)testSetTexCoords
{
    SPImage *image = [[SPImage alloc] init];
    [image setTexCoords:[SPPoint pointWithX:1 y:2] ofVertex:0];
    [image setTexCoords:[SPPoint pointWithX:3 y:4] ofVertex:1];
    [image setTexCoords:[SPPoint pointWithX:5 y:6] ofVertex:2];
    [image setTexCoords:[SPPoint pointWithX:7 y:8] ofVertex:3];    
    
    STAssertEqualObjects([SPPoint pointWithX:1 y:2], [image texCoordsOfVertex:0], @"wrong tex coords!");    
    STAssertEqualObjects([SPPoint pointWithX:3 y:4], [image texCoordsOfVertex:1], @"wrong tex coords!");    
    STAssertEqualObjects([SPPoint pointWithX:5 y:6], [image texCoordsOfVertex:2], @"wrong tex coords!");    
    STAssertEqualObjects([SPPoint pointWithX:7 y:8], [image texCoordsOfVertex:3], @"wrong tex coords!");
    [image release];    
}

@end

#endif