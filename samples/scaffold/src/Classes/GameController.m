//
//  GameController.m
//  AppScaffold
//

#import "GameController.h"

@implementation GameController

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        mGame = [[Game alloc] initWithWidth:width height:height];
        
        mGame.pivotX = mGame.x = width  / 2;
        mGame.pivotY = mGame.y = height / 2;
        
        [self addChild:mGame];
    }
    
    return self;
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    float angles[] = {0.0f, 0.0f, PI, PI_HALF, -PI_HALF};
    
    float oldAngle = mGame.rotation;
    float newAngle = angles[(int)interfaceOrientation];
    
    // make sure that rotation is always carried out via the minimal angle
    while (oldAngle - newAngle >  PI) newAngle += TWO_PI;
    while (oldAngle - newAngle < -PI) newAngle -= TWO_PI;

    SPTween *tween = [SPTween tweenWithTarget:mGame time:INTERFACE_ROTATION_TIME 
                                   transition:SP_TRANSITION_EASE_IN_OUT];
    [tween animateProperty:@"rotation" targetValue:newAngle];
    [[SPStage mainStage].juggler removeObjectsWithTarget:mGame];
    [[SPStage mainStage].juggler addObject:tween];
}

- (void)dealloc
{
    [mGame release];
    [super dealloc];
}

@end
