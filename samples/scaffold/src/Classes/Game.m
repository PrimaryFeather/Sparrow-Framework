//
//  Game.m
//  AppScaffold
//

#import "Game.h" 

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        // This is where the code of your game will start. 
        // In this sample, we add just a few simple elements to see if it works.
        // 
        // The Application contains a very hand "Media" class which loads your texture atlas
        // and all available sound files automatically. Extend this class as you need it --
        // that way, you will be able to access your textures and sounds throughout your 
        // application, without duplicating any resources.
        
        
        // Create a background image
        
        SPImage *background = [[SPImage alloc] initWithContentsOfFile:@"Default.png"];
        [self addChild:background];
        
        
        // Display the Sparrow egg
        
        SPImage *egg = [[SPImage alloc] initWithTexture:[Media atlasTexture:@"egg"]];
        egg.pivotX = (int)egg.width / 2;
        egg.pivotY = (int)egg.height / 2;
        egg.x = CENTER_X;
        egg.y = CENTER_Y;
        [self addChild:egg];
        
        // play a sound when the egg is touched
        [egg addEventListener:@selector(onEggTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        // and animate it a little
        SPTween *tween = [SPTween tweenWithTarget:egg time:5.0 transition:SP_TRANSITION_EASE_IN_OUT];
        [tween animateProperty:@"rotation" targetValue:SP_D2R(360)];
        tween.loop = SPLoopTypeRepeat;
        [[SPStage mainStage].juggler addObject:tween];
        
        
        // Create a text field
        
        NSString *text = @"To find out how to create your own game out of this scaffold, " \
                         @"have a look at the 'Getting Started' section of the Sparrow " \
                         @"website!";
        
        SPTextField *textField = [[SPTextField alloc] initWithWidth:280 height:80 text:text];
        textField.x = 20;
        textField.y = 460 - textField.height;
        textField.vAlign = SPVAlignBottom;
        [self addChild:textField];
        
        
        // We release the objects, because we don't keep any reference to them.
        // (Their parent display objects will take care of them.)
        // 
        // However, if you don't want to bother with memory management, feel free to convert this
        // project to ARC (Automatic Reference Counting) by clicking on 
        // "Edit - Refactor - Convert to Objective-C ARC".
        // Those lines will then be removed from the project.
        
        [background release];
        [egg release];
        [textField release];
        
        
        // Per default, this project compiles as an iPhone application. To change that, enter the 
        // project info screen, and in the "Build"-tab, find the setting "Targeted device family".
        //
        // Now Choose:  
        //   * iPhone      -> iPhone only App
        //   * iPad        -> iPad only App
        //   * iPhone/iPad -> Universal App  
        // 
        // If you want to support the iPad, you have to change the "iOS deployment target" setting
        // to "iOS 3.2" (or "iOS 4.2", if it is available.)
    }
    return self;
}

- (void)onEggTouched:(SPTouchEvent *)event
{
    NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseEnded];
    if ([touches anyObject])
        [Media playSound:@"sound.caf"];
}

@end
