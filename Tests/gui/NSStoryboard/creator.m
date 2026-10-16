/* -[NSStoryboard instantiateControllerWithIdentifier:creator:] calls the
   creator block once with a coder for the scene and answers the
   controller the block returns, with the view of the scene.  A block
   that returns nil gets the storyboard's controller.  The block used to
   be given the storyboard, after the controller was made, and what it
   returned was ignored.  GNUstep declares NSStoryboardControllerCreator
   with the result typed as NSCoder, so the block's controller is cast.
   Loading the controllers needs the backend, so the set is skipped when
   the backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSCoder.h>
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

@interface MadeController : NSViewController
@end
@implementation MadeController
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
  NSStoryboard *storyboard;
  MadeController *made;
  __block int calls = 0;
  __block id argument = nil;
  id controller;

  START_SET("NSStoryboard creator")

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
  made = AUTORELEASE([[MadeController alloc] initWithNibName: nil bundle: nil]);

  controller = [storyboard instantiateControllerWithIdentifier: @"DetailIdentifier"
    creator: ^NSCoder *(id coder) {
      calls++;
      argument = coder;
      return (NSCoder *)made;
    }];
  PASS(calls == 1, "the creator block is called once");
  PASS([argument isKindOfClass: [NSCoder class]],
    "the creator block is given a coder");
  PASS(controller == made,
    "the controller the creator block returns is answered");
  PASS(NSEqualSizes([[made view] frame].size, NSMakeSize(90, 60)),
    "the creator's controller has the view of the scene");

  controller = [storyboard instantiateControllerWithIdentifier: @"DetailIdentifier"
    creator: ^NSCoder *(id coder) {
      return nil;
    }];
  PASS([controller isKindOfClass: [DetailController class]],
    "a creator block that returns nil gets the storyboard's controller");

  END_SET("NSStoryboard creator")

  [pool release];
  return 0;
}
