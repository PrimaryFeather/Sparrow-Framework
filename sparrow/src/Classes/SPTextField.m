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
@synthesize fontColor = mFontColor;
@synthesize hAlign = mHAlign;
@synthesize vAlign = mVAlign;
@synthesize background = mBackground;
@synthesize backgroundColor = mBackgroundColor;
@synthesize border = mBorder;
@synthesize borderColor = mBorderColor;
@synthesize texture = mTexture;

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name 
          fontColor:(uint)color fontSize:(float)size
{
    if (self = [super initWithWidth:width height:height])
    {    
        mText = [text copy];
        mFontColor = color;
        mFontName = [name copy];
        mFontSize = size;
        mHAlign = SPHAlignCenter;
        mVAlign = SPVAlignCenter;
        mBackground = NO;
        mBackgroundColor = 0xffffff;
        mBorder = NO;
        mBorderColor = 0x0;       
        mTexture = nil;        
        mRequiresRedraw = YES;                
        [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    }    
    return self;
} 

- (id)initWithWidth:(float)width height:(float)height text:(NSString*)text;
{
    return [self initWithWidth:width height:height text:text fontName:SP_DEFAULT_FONT_NAME
                     fontColor:SP_DEFAULT_FONT_COLOR fontSize:SP_DEFAULT_FONT_SIZE];   
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
    SP_CREATE_POOL(pool);
    
    int legalWidth = 2;    while (legalWidth < mWidth) legalWidth *= 2;
    int legalHeight = 2;   while (legalHeight < mHeight) legalHeight *=2;
    
    SPPoint *textSize = [self textSize];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(legalWidth * legalHeight * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, legalWidth, legalHeight,
                                                 8, 4 * legalWidth, colorSpace, 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, CGRectMake(0, 0, legalWidth, legalHeight));
    
    // NSString draws in UIKit referential -> that's upside-down compared to CGBitmapContext!
    // thus, we flip it.
    CGContextTranslateCTM(context, 0.0f, legalHeight);
	CGContextScaleCTM(context, 1.0f, -1.0f); 
    
    UIGraphicsPushContext(context);    
    
    if (mBackground)
    {
        CGContextSetRGBFillColor(context, SP_COLOR_PART_RED(mBackgroundColor) / 255.0f, 
                                          SP_COLOR_PART_GREEN(mBackgroundColor) / 255.0f,  
                                          SP_COLOR_PART_BLUE(mBackgroundColor) / 255.0f, 1.0f);     
        CGContextFillRect(context, CGRectMake(0, 0, mWidth, mHeight));
    }
    
    if (mBorder)
    {
        CGContextSetRGBStrokeColor(context, SP_COLOR_PART_RED(mBorderColor) / 255.0f, 
                                            SP_COLOR_PART_GREEN(mBorderColor) / 255.0f,  
                                            SP_COLOR_PART_BLUE(mBorderColor) / 255.0f, 1.0f);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeRect(context, CGRectMake(0.5f, 0.5f, mWidth-1, mHeight-1));
    }
    
    CGContextSetRGBFillColor(context, SP_COLOR_PART_RED(mFontColor) / 255.0f, 
                                      SP_COLOR_PART_GREEN(mFontColor) / 255.0f,  
                                      SP_COLOR_PART_BLUE(mFontColor) / 255.0f, 1.0f);     
    
    UILineBreakMode lbm = UILineBreakModeTailTruncation;
 
    float yOffset = 0;
    if (mVAlign == SPVAlignCenter)      yOffset = (mHeight - textSize.y) / 2.0f;
    else if (mVAlign == SPVAlignBottom) yOffset = mHeight - textSize.y;    
    
    [mText drawInRect:CGRectMake(0, yOffset, mWidth, mHeight)
             withFont:[UIFont fontWithName:mFontName size:mFontSize] 
        lineBreakMode:lbm alignment:mHAlign];
    
    UIGraphicsPopContext();
    
    SPTexture* texture = [[SPStaticTexture alloc] initWithData:imageData width:legalWidth height:legalHeight];
    texture.clipping = [SPRectangle rectangleWithX:0 y:0 width:mWidth/legalWidth height:mHeight/legalHeight];    
    
    CGContextRelease(context);
    free(imageData);
    
    SP_RELEASE_POOL(pool);
    
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

- (void)setText:(NSString*)text
{
    if (![text isEqualToString:mText])
    {
        [mText release];
        mText = [text copy];
        mRequiresRedraw = YES;
    }
}

- (void)setFontName:(NSString*)fontName
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

- (void)setFontColor:(uint)fontColor
{
    if (fontColor != mFontColor)
    {
        mFontColor = fontColor;
        mRequiresRedraw = YES;
    }
}

- (void)setBackground:(BOOL)background
{
    if (background != mBackground)
    {
        mBackground = background;
        mRequiresRedraw = YES;
    }
}

- (void)setBackgroundColor:(uint)color
{
    if (color != mBackgroundColor)
    {
        mBackgroundColor = color;
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

- (void)setBorderColor:(uint)borderColor
{
    if (borderColor != mBorderColor)
    {
        mBorderColor = borderColor;
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

+ (SPTextField*)textFieldWithWidth:(float)width height:(float)height text:(NSString*)text fontName:(NSString*)name
               fontColor:(uint)color fontSize:(float)size
{
    return [[[SPTextField alloc] initWithWidth:width height:height text:text fontName:name 
                                     fontColor:color fontSize:size] autorelease];
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
