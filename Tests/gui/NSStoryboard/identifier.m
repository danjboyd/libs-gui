/* -[NSStoryboard instantiateControllerWithIdentifier:] finds a controller by
   its storyboard identifier, the identifier set in Interface Builder.  The
   storyboard used to map only the controllers' element ids to scenes, so a
   lookup by storyboard identifier raised.  A lookup by element id keeps
   working.
   Loading the controllers needs the backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSFileManager.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSStoryboard.h>
#include <AppKit/NSView.h>
#include <AppKit/NSViewController.h>

@interface MainController : NSViewController
@end
@implementation MainController
@end

@interface DetailController : NSViewController
@end
@implementation DetailController
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
  NSStoryboard *storyboard;
  id controller;

  START_SET("NSStoryboard identifiers")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  storyboard = [NSStoryboard storyboardWithName: @"Identifiers"
    bundle: AUTORELEASE([[NSBundle alloc] initWithPath: path])];
  PASS(storyboard != nil, "the storyboard loads");

  controller = [storyboard instantiateInitialController];
  PASS([controller isKindOfClass: [MainController class]],
    "the initial controller is instantiated");

  controller = nil;
  NS_DURING
    {
      controller = [storyboard
        instantiateControllerWithIdentifier: @"DetailIdentifier"];
    }
  NS_HANDLER
    {
    }
  NS_ENDHANDLER
  PASS([controller isKindOfClass: [DetailController class]],
    "a controller is instantiated by its storyboard identifier");
  PASS(NSEqualSizes([[controller view] frame].size, NSMakeSize(90, 60)),
    "the controller has the view of its scene");

  controller = [storyboard instantiateControllerWithIdentifier: @"DetailController"];
  PASS([controller isKindOfClass: [DetailController class]],
    "a controller is still instantiated by its element id");

  END_SET("NSStoryboard identifiers")

  [pool release];
  return 0;
}
