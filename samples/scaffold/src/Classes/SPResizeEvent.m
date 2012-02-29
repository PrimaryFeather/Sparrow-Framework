//
//  SPResizeEvent.m
//  AppScaffold
//

#import "SPResizeEvent.h"

@implementation SPResizeEvent

@synthesize width = mWidth;
@synthesize height = mHeight;
@synthesize animationTime = mAnimationTime;

- (id)initWithType:(NSString *)type width:(float)width height:(float)height 
     animationTime:(double)time
{
    if ((self = [super initWithType:type bubbles:NO]))
    {
        mWidth = width;
        mHeight = height;
        mAnimationTime = time;
    }
    return self;
}

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [self initWithType:type width:320 height:480 animationTime:0.5];
}

- (BOOL)isPortrait
{
    return mHeight > mWidth;
}

@end
