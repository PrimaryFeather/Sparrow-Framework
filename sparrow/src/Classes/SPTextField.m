//
//  SPTextField.m
//  Sparrow
//
//  Created by Daniel Sperl on 29.06.09.
//  Copyright 2009 Incognitek. All rights reserved.
//

#import "SPTextField.h"
#import "SPTexture.h"
#import "SPStaticTexture.h"
#import "SPMakros.h"
#import "SPEnterFrameEvent.h"

#import <UIKit/UIKit.h>

// --- private interface ---------------------------------------------------------------------------

@interface SPTextField()

@property (nonatomic, retain) SPTexture *texture;
@property (nonatomic, readonly) SPPoint *textSize;

- (SPTexture*)createTexture;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPTextField

@synthesize text = mText;
@synthesize fontName = mFontName;
@synthesize fontSize = mFontSize;
@synthesize hAlign = mHAlign;
@synthesize vAlign = mVAlign;
@synthesize border = mBorder;
@synthesize texture = mTexture;

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name 
          fontSize:(float)size color:(uint)color 
{
    if (self = [super initWithWidth:width height:height])
    {    
        mText = [text copy];
        self.color = color;
        mFontName = [name copy];
        mFontSize = size;
        mHAlign = SPHAlignCenter;
        mVAlign = SPVAlignCenter;
        mBorder = NO;
        mTexture = nil;        
        mRequiresRedraw = YES;                
        [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    }    
    return self;
} 

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text;
{
    return [self initWithWidth:width height:height text:text fontName:SP_DEFAULT_FONT_NAME
                     fontSize:SP_DEFAULT_FONT_SIZE color:SP_DEFAULT_FONT_COLOR];   
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithWidth:width height:height text:@""];
}

- (void)onEnterFrame:(SPEnterFrameEvent*)event
{
    if (mRequiresRedraw)
    {    
        self.texture = [self createTexture];
        mRequiresRedraw = NO;     
    }
}

- (SPTexture*)createTexture
{
    int legalWidth  = 2;   while (legalWidth  < mWidth)  legalWidth  *= 2;
    int legalHeight = 2;   while (legalHeight < mHeight) legalHeight *= 2;
    
    SPPoint *textSize = [self textSize];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    void *imageData = malloc(legalWidth * legalHeight);
    CGContextRef context = CGBitmapContextCreate(imageData, legalWidth, legalHeight,
                                                 8, legalWidth, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, CGRectMake(0, 0, legalWidth, legalHeight));
    
    // NSString draws in UIKit referential -> that's upside-down compared to CGBitmapContext!
    // thus, we flip it.
    CGContextTranslateCTM(context, 0.0f, legalHeight);
	CGContextScaleCTM(context, 1.0f, -1.0f); 
    
    UIGraphicsPushContext(context);    
    
    if (mBorder)
    {
        CGContextSetGrayStrokeColor(context, 1.0f, 1.0f);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeRect(context, CGRectMake(0.5f, 0.5f, mWidth-1, mHeight-1));
    }
        
    CGContextSetGrayFillColor(context, 1.0f, 1.0f);
    UILineBreakMode lbm = UILineBreakModeTailTruncation;
 
    float yOffset = 0;
    if (mVAlign == SPVAlignCenter)      yOffset = (mHeight - textSize.y) / 2.0f;
    else if (mVAlign == SPVAlignBottom) yOffset =  mHeight - textSize.y;    
    
    [mText drawInRect:CGRectMake(0, yOffset, mWidth, mHeight)
             withFont:[UIFont fontWithName:mFontName size:mFontSize] 
        lineBreakMode:lbm alignment:mHAlign];
    
    UIGraphicsPopContext();
    
    SPTexture* texture = [[SPStaticTexture alloc] initWithData:imageData 
        width:legalWidth height:legalHeight format:SPTextureFormatAlpha premultipliedAlpha:NO];

    texture.clipping = [SPRectangle rectangleWithX:0 y:0 width:mWidth/legalWidth height:mHeight/legalHeight];    
    
    CGContextRelease(context);
    free(imageData);
    
    return [texture autorelease];    
}

#pragma mark -

- (void)setWidth:(float)width
{
    // other than in SPDisplayObject, changing the size of the object should not change the scaling;
    // changing the size should just make the texture bigger/smaller, 
    // keeping the size of the text/font unchanged. (this applies to setHeight:, as well.)
    
    mWidth = (mWidth / self.width) * width;
    mRequiresRedraw = YES;
}

- (void)setHeight:(float)height
{
    mHeight = (mHeight / self.height) * height;
    mRequiresRedraw = YES;
}

- (SPPoint*)textSize
{
    CGSize textSize = [mText sizeWithFont:[UIFont fontWithName:mFontName size:mFontSize] 
                        constrainedToSize:CGSizeMake(mWidth, mHeight) 
                            lineBreakMode:UILineBreakModeHeadTruncation];
    return [SPPoint pointWithX:textSize.width y:textSize.height];
}

- (float)textWidth
{
    return [self textSize].x;
}

- (float)textHeight
{
    return [self textSize].y;
}

- (void)setText:(NSString *)text
{
    if (![text isEqualToString:mText])
    {
        [mText release];
        mText = [text copy];
        mRequiresRedraw = YES;
    }
}

- (void)setFontName:(NSString *)fontName
{
    if (![fontName isEqualToString:mFontName])
    {
        [mFontName release];
        mFontName = [fontName copy];
        mRequiresRedraw = YES;
    }
}

- (void)setFontSize:(float)fontSize
{
    if (fontSize != mFontSize)
    {
        mFontSize = fontSize;
        mRequiresRedraw = YES;
    }
}
 
- (void)setBorder:(BOOL)border
{
    if (border != mBorder)
    {
        mBorder = border;
        mRequiresRedraw = YES;
    }
}
 
- (void)setHAlign:(SPHAlign)hAlign
{
    if (hAlign != mHAlign)
    {
        mHAlign = hAlign;
        mRequiresRedraw = YES;
    }
}

- (void)setVAlign:(SPVAlign)vAlign
{
    if (vAlign != mVAlign)
    {
        mVAlign = vAlign;
        mRequiresRedraw = YES;
    }
}

+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text 
                          fontName:(NSString*)name fontSize:(float)size color:(uint)color
{
    return [[[SPTextField alloc] initWithWidth:width height:height text:text fontName:name 
                                     fontSize:size color:color] autorelease];
}

+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text
{
    return [[[SPTextField alloc] initWithWidth:width height:height text:text] autorelease];
}

#pragma mark -

- (void)dealloc
{
    [self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    [mText release];
    [mFontName release];
    [mTexture release];
    [super dealloc];
}

@end
