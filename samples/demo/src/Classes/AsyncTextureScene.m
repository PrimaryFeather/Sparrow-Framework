//
//  AsyncTextureScene.m
//  Demo
//
//  Created by Daniel Sperl on 12.02.13.
//
//

#import "AsyncTextureScene.h"

@implementation AsyncTextureScene
{
    SPButton *mFileButton;
    SPButton *mUrlButton;
    SPTextField *mLogText;
    SPImage *mFileImage;
    SPImage *mUrlImage;
}

- (id)init
{
    if ((self = [super init]))
    {
        SPTexture *buttonTexture = [SPTexture textureWithContentsOfFile:@"button_normal.png"];
        
        mFileButton = [SPButton buttonWithUpState:buttonTexture text:@"Load from File"];
        mFileButton.x = 20;
        mFileButton.y = 20;
        [mFileButton addEventListener:@selector(onFileButtonTriggered:) atObject:self
                              forType:SP_EVENT_TYPE_TRIGGERED];
        [self addChild:mFileButton];
        
        mUrlButton = [SPButton buttonWithUpState:buttonTexture text:@"Load from Web"];
        mUrlButton.x = 300 - mUrlButton.width;
        mUrlButton.y = 20;
        [mUrlButton addEventListener:@selector(onUrlButtonTriggered:) atObject:self
                              forType:SP_EVENT_TYPE_TRIGGERED];
        [self addChild:mUrlButton];

        mLogText = [SPTextField textFieldWithWidth:280 height:50 text:@""
                                            fontName:@"Verdana" fontSize:12 color:0x0];
        mLogText.x = 20;
        mLogText.y = mFileButton.y + mFileButton.height + 5;
        [self addChild:mLogText];
    }
    return self;
}

- (void)onFileButtonTriggered:(SPEvent *)event
{
    mFileImage.visible = NO;
    mLogText.text = @"Loading texture ...";
    
    [SPTexture loadFromFile:@"async_local.png"
                 onComplete:^(SPTexture *texture, NSError *outError)
    {
        if (outError)
            mLogText.text = [outError localizedDescription];
        else
        {
            mLogText.text = @"File loaded successfully.";
            
            if (!mFileImage)
            {
                mFileImage = [[SPImage alloc] initWithTexture:texture];
                mFileImage.x = (int)(self.stage.width - texture.width) / 2;
                mFileImage.y = 110;
                [self addChild:mFileImage];
            }
            else
            {
                mFileImage.visible = YES;
                mFileImage.texture = texture;
            }
        }
    }];
}

- (void)onUrlButtonTriggered:(SPEvent *)event
{
    mUrlImage.visible = NO;
    mLogText.text = @"Loading texture ...";
    
    // If your texture name contains a suffix like "@2x", you can use
    // "[SPTexture loadTextureFromSuffixedURL:...]". In this case, we have
    // no control over the image name, so we assign the scale factor directly.
    
    float scale = Sparrow.contentScaleFactor;
    NSURL *url = scale == 1.0f ? [NSURL URLWithString:@"http://i.imgur.com/24mT16x.png"] :
                                 [NSURL URLWithString:@"http://i.imgur.com/kE2Bqnk.png"];
    
    [SPTexture loadFromURL:url generateMipmaps:NO scale:scale
                onComplete:^(SPTexture *texture, NSError *outError)
     {
         if (outError)
             mLogText.text = [outError localizedDescription];
         else
         {
             mLogText.text = @"File loaded successfully.";
             
             if (!mUrlImage)
             {
                 mUrlImage = [[SPImage alloc] initWithTexture:texture];
                 mUrlImage.x = (int)(self.stage.width - texture.width) / 2;
                 mUrlImage.y = 275;
                 [self addChild:mUrlImage];
             }
             else
             {
                 mUrlImage.visible = YES;
                 mUrlImage.texture = texture;
             }
         }
     }];
}

@end
