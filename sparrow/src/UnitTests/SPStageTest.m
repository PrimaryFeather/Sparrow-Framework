//
//  SPStageTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 25.04.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "SPMatrix.h"
#import "SPMakros.h"
#import "SPPoint.h"
#import "SPSprite.h"
#import "SPStage.h"

// -------------------------------------------------------------------------------------------------

@interface SPStageTest : SenTestCase 

@end

// -------------------------------------------------------------------------------------------------

@implementation SPStageTest

- (void) setUp
{
}

- (void) tearDown
{
}

#pragma mark -

- (void)testForbiddenProperties
{
    SPStage *stage = [[SPStage alloc] init];
    STAssertThrows([stage setX:10], @"allowed to set x coordinate of stage");
    STAssertThrows([stage setY:10], @"allowed to set y coordinate of stage");
    STAssertThrows([stage setScaleX:2.0], @"allowed to scale stage");
    STAssertThrows([stage setScaleY:2.0], @"allowed to scale stage");
    STAssertThrows([stage setRotationZ:PI], @"allowed to rotate stage");
}

@end