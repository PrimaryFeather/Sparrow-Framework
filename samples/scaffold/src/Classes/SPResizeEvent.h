//
//  SPResizeEvent.h
//  AppScaffold
//

#import "SPEvent.h"

#define SP_EVENT_TYPE_RESIZE @"resize"

@interface SPResizeEvent : SPEvent
{
  @private
    float mWidth;
    float mHeight;
    double mAnimationTime;
}

- (id)initWithType:(NSString *)type width:(float)width height:(float)height 
     animationTime:(double)time;

@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic, readonly) double animationTime;
@property (nonatomic, readonly) BOOL isPortrait;

@end
