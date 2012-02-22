Sparrow: Changelog
==================

version 1.2 - 2011-05-22
------------------------

- added pivotX- and pivotY-property to SPDisplayObject to allow manipulation of the origin point
- added support for GZip'ed PVR textures
- added support for texture frames aka trimmed textures
- added kerning to bitmap fonts (if the font file contains kerning information)
- added [SPStage mainStage] method for quick access to the stage
- added ability to choose between nearest neighbor, bilinear and trilinear texture filtering
- added 'moveToX:y' and 'scaleTo:' methods to SPTween
- added support for RGBA8888 texture format
- added support for tweening unsigned integers
- added events on each loop of an SPMovieClip
- added support for directories when loading resource files; in iOS 3.x, that did not work before.
- added color property to stage
- added [NSBundle appBundle] extension method. This method is now used throughout the framework 
  instead of [NSBundle mainBundle]. That way, unit tests will find their resource files, too.
- updated button to behave just like a textfield: the text does not stretch any longer
  when width or height are changed
- updated projects for Xcode4
- updated xml parsing to work around memory leak
- fixed bounds-optimization of SPQuad, which might have failed in subclasses
- fixed path handling of bitmap font and atlas classes
- fixed that HD textures were only found within application bundle
- fixed texture binding problems of SPRenderTexture
- fixed generate_atlas.rb script to work with Ruby 1.9
- fixed looping behavior of tween and movie clip
- fixed wrong scale setting when loading bitmap font with custom texture
- fixed bug that caused Sparrow to treat new touch as if it was an existing one
- fixed name of random number method because of conflicting keyword 'and'
- fixed clearWithColor method
- Special thanks to 
  - Shilo White for the Pivot Point
  - Ludometrics for Bitmap Font kerning
  - Tadas Vilkeliskis for tweening of unsigned integers
  - Jonathan Shieh for his fix that allows unit tests to load files
  - Andreas Wålm for making generate_atlas.rb work with ruby 1.9
  - numerous forum members for bug reports, suggestions and feedback!

version 1.1 - 2011-01-12
------------------------

- added SPRenderTexture
- added SPUtils class for easy random number generation (more to come)
- added support for looping and reversing tweens (thanks, Shilo!)
- added new transition method: 'randomize'
- added support for uncompressed PVR texture formats (565, 5551, 4444)
- added simple way to use HD textures on the iPad
- added support for creating dynamic texture atlases (add/remove regions on the fly)
- added methods to access the glyphs of SPBitmapFont directly
- added new init method to SPImage: 'initWithContentsOfImage:(UIImage *)image'
- added more factory methods to different classes
- added support for changing the fps of SPMovieClip at runtime (thanks Shilo!)
- added AppleDoc inline API documentation
- added bash script that generates API documentation
- updated SPView class to be more robust
- updated general rendering code (moved more OpenGL calls to SPRenderTexture)
- fixed bug with canceled touch events
- fixed bug that could cause a breakdown of the touch handling (thanks Kodi!)
- fixed 'isEqual' method of SPMatrix (thanks Matt!)
- fixed bug that could cut the outermost pixels of HD textures
- Special thanks to numerous forum members for bug reports, suggestions and feedback!

version 1.0 - 2010-10-24
------------------------

- added support for PVRTC-textures
- added new init method to SPTexture to allow simple use of Core Graphics drawings
- added new init method to SPMovieClip that uses an NSArray containing the frames
- added method 'childByName:' to SPDisplayObjectContainer
- added method 'texturesStartingWith:' to SPTextureAtlas
- added method 'scaleBy:' to SPPoint
- added method 'interpolateFromPoint:toPoint:ratio:' to SPPoint
- added property 'textBounds' to SPTextField
- added property 'name' to SPDisplayObject
- added workaround for unit test problem in Xcode 3.2.4
- updated SPCompiledSprite-class to be public
- updated texture utilities for sharper output
- updated scaffold so that it is easier to create an iPad application
- fixed bug that classes inheriting directly from SPQuad were not rendered
- fixed that last-moment changes were not displayed when pausing stage
- fixed bug that could lead to a white flash when textures were released
- Special thanks to numerous forum members for bug reports, suggestions and feedback!

version 0.9 - 2010-07-30
------------------------

- !!! interface change !!! 
  The IDs of vertices in SPQuad and SPImage have changed. ("colorOfVertex:", "texCoordsOfVertex:")
  Before: 0 = top left, 1 = top right, 2 = bottom right, 3 = bottom left
  AFTER:  0 = top left, 1 = top right, 2 = bottom left,  3 = bottom right
- greatly improved rendering speed of SPTextField when used with bitmap fonts 
- greatly improved performance of touch event analysis
- added Sparrow atlas generator (sparrow/util/atlas_generator)
- added Sparrow texture resizer (sparrow/util/texture_scaler)
- added support for high resolution screens (aka iPhone4's retina display)
- added support for high resolution textures ("texture@2x.png")
- added support for high resolution texture atlases ("atlas@2x.xml")
- added support for high resolution bitmap fonts ("font@2x.xml")
- added support for loading textures that are not inside the application bundle
- added support for loading sounds that are not inside the application bundle
- changed base SDK to iOS 4.0
- added new event: SP_EVENT_TYPE_MOVIE_COMPLETED in SPMovieClip class
- added experimental feature: SPCompiledSprite
- added some missing "@private" declarations
- fixed memory access violation when object was destroyed within an enter frame event listener
- fixed bug that alpha values were only used when a texture was active
- fixed bug that SPDelayedInvocation (aka SPJuggler::delayInvocationAtTarget) did not retain
  its arguments 
- fixed bug that cancelled touch events would inhibit further user input
- code cleanup (especially concerning designated initializers)
- Special thanks to: Mike, Baike, Paolo, Jule and Alex_H for bug reports, suggestions and feedback!

version 0.8 - 2010-06-05
------------------------

- added audio classes
- added SPMovieClip class
- added new transition functions:
    - easeInBack / easeOutBack / easeInOutBack / easeOutInBack
    - easeInElastic / easeOutElastic / easeInOutElastic / easeOutInElastic
    - easeInBounce / easeOutBounce / easeInOutBounce / easeOutInBounce
- added 'removeTweensWithTarget:'-method to juggler
- added 'removeAllChildren'-method to SPDisplayObjectContainer
- added new text-only constructor to SPTextField
- added NSXMLParserDelegate protocol statement for iPhone SDK 4+
- added packer2sparrow utility
- added hiero2sparrow utility
- changed transition function signature (removed delta)
- changed rotation handling: angles now clamped from -180 to +180 degrees.
  this should make most rotation tweens more intuitive.
- changed license text to allow easy AppStore distribution
- changed scaffold project to support audio
- changed demo project
    - new design
    - new scene: sound 
    - new scene: movie
- fixed touch issues when view size != stage size
- fixed exception that occurred when the same object was added to a container twice
- fixed flickering at application start
- fixed method signatures in SPTexture.m
- 'removeChild'-method in SPDisplayObjectContainer no longer throws an exception when the 
  object is not a child, but now silently ignores the failure.
- the stage property is now accessible in the REMOVED_FROM_STAGE event
- disabled unit test execution in iPhone SDK < 3 (unit tests are only supported by iPhone SDK 3+)

version 0.7 - 2010-01-14
------------------------

- first public version 
