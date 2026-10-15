/* There is one shared media library browser controller, and it keeps
   whether it is visible, which -togglePanel: flips.  The shared controller
   was nil.  It needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSMediaLibraryBrowserController.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMediaLibraryBrowserController *c;

  START_SET("NSMediaLibraryBrowserController")

  c = [NSMediaLibraryBrowserController sharedMediaLibraryBrowserController];
  PASS(c != nil, "there is a shared controller");
  PASS(c == [NSMediaLibraryBrowserController sharedMediaLibraryBrowserController],
    "the shared controller is the same each time");
  PASS(![c isVisible], "the browser is hidden at first");
  [c setVisible: YES];
  PASS([c isVisible], "the browser can be made visible");
  [c togglePanel: nil];
  PASS(![c isVisible], "togglePanel: hides a visible browser");

  END_SET("NSMediaLibraryBrowserController")

  [pool release];
  return 0;
}
