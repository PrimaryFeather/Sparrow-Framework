Sparrow: Tips for building an app
=================================

A First look at Sparrow
-----------------------

In the folder “samples/demo”, you will find an Xcode project that shows the most basic Sparrow
features and how to use them. Just open the project in Xcode, compile and run - everything should
work out of the box.

Creating a new Xcode project that uses Sparrow
----------------------------------------------

In the folder “samples/scaffold”, you will find an Xcode project that contains a bare-bone Sparrow 
application. Follow these simple steps to use it as a basis for your game:

### Preconditions: ###

Sparrow is linked to your application via Xcode project references. This has the advantage that it's
easy to update Sparrow (just download a new release and overwrite the old one in the same directory)
and that you can easily step into Sparrow source code, in case you want to do so.

### This has to be done only once: ###

**Xcode 3 and 4**

Add a “Source Tree” variable that Xcode can use to dynamically find Sparrow:

  * In the Xcode preferences, tab: “Source Trees”, create a new Source Tree variable.
  * Create SPARROW_SRC and let it point to /path_to_sparrow/sparrow/src/
  * Be careful: Xcode does not allow any spaces in that path.

**Xcode 3 only**

Set up a shared build output directory that will be shared by all Xcode projects:

  * In the Xcode preferences, tab: “Building”, set “Place Build Products in” to 
    “Customized location” and specify a common build directory (anywhere you want).
  * Set “Place Intermediate Build Files in” to “With build products”.

### Creating your new project: ###

In the folder “samples/scaffold”, you will find an Xcode project that contains a bare-bone Sparrow 
application. Follow these simple steps to use it as a basis for your game:

  * Copy the “scaffold”-folder to the place where you want to have your game project.
  * Open “AppScaffold.xcodeproj”
  * Build and run — just to see if everything works fine. If it does not work, check if you have 
    created the `SPARROW_SRC` variable in Xcode, and if it points to the right place.
  * Rename the project:
    * Xcode 3: click on “Project” → “Rename …” and enter the name of your choice.
    * Xcode 4: select the project in the Project Navigator, then open the file inspector and change 
               the text in the “Project Name” field. Accept the requests of the appearing popups.
  * That’s it! Now you can start to develop your game with Sparrow.

After creating your project, you can choose the target hardware (iPhone / iPad / Universal) 
in the project’s build settings (search for “Targeted Device Family”).

### Optional: Integrating the API documentation (optional) ###

Open up the Xcode preferences and enter the “Documentation”-tab. Add the following publisher:

    http://doc.sparrow-framework.org/core/feed/docset.atom

Now you can get information about Sparrow classes and methods with the following shortcuts:

  * Xcode 3: Option double-click on symbol
  * Xcode 4: Option single-click on symbol