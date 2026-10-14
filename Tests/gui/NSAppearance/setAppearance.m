/* NSAppearance does not adopt NSCopying, and AppKit's appearance properties
   are strong, so -setAppearance: of NSView and NSApplication must retain the
   appearance rather than copy it: copying raised for every appearance.
   NSApplication adopts NSAppearanceCustomization as NSView does.
   The view and the application need the backend, so the set is skipped when
   the backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSAppearance.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSAppearance *appearance;
  NSView *view;

  START_SET("setAppearance:")

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

  appearance = [NSAppearance appearanceNamed: NSAppearanceNameDarkAqua];
  view = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);

  PASS_RUNS([view setAppearance: appearance],
    "a view's appearance can be set");
  PASS([view appearance] == appearance,
    "a view keeps the appearance it is given");
  PASS([view effectiveAppearance] == appearance,
    "a view's effective appearance is its own appearance");
  PASS_RUNS([view setAppearance: nil],
    "a view's appearance can be cleared");
  PASS([view appearance] == nil,
    "a cleared view appearance is nil");

  PASS([NSApp conformsToProtocol: @protocol(NSAppearanceCustomization)],
    "NSApplication adopts NSAppearanceCustomization");
  PASS_RUNS([NSApp setAppearance: appearance],
    "the application's appearance can be set");
  PASS([NSApp appearance] == appearance,
    "the application keeps the appearance it is given");
  PASS([NSApp effectiveAppearance] == appearance,
    "the application's effective appearance is its own appearance");
  [NSApp setAppearance: nil];

  END_SET("setAppearance:")

  [pool release];
  return 0;
}
