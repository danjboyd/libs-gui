/* -iconForFiles: answers an icon for several files: the multiple selection
   image libs-gui ships.  It used to ask for an image that does not exist,
   and answered nil.  The workspace needs the backend, so the set is
   skipped without it. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSImage.h>
#include <AppKit/NSWorkspace.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSImage *icon;
  NSImage *again;
  NSArray *files;
  NSArray *others;

  START_SET("NSWorkspace iconForFiles:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  files = [NSArray arrayWithObjects: @"/tmp", @"/", nil];
  others = [NSArray arrayWithObjects: @"/", @"/tmp", nil];
  icon = [[NSWorkspace sharedWorkspace] iconForFiles: files];
  again = [[NSWorkspace sharedWorkspace] iconForFiles: others];
  PASS(icon != nil, "several files have an icon");
  PASS(icon == again, "the icon for several files is the same each time");

  END_SET("NSWorkspace iconForFiles:")

  [pool release];
  return 0;
}
