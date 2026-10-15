/* The help panel answers the help file it was last asked to show.
   -helpFile answered nil, as nothing set it.  A file that does not exist
   gives no help to show, so no modal loop is run.  The panel needs the
   backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/Foundation.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSHelpPanel.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSHelpPanel *panel = nil;
  NSString *dir = @"/nonexistent-gnustep-help";

  START_SET("NSHelpPanel helpFile")

  NS_DURING
    {
      [NSApplication sharedApplication];
      panel = [NSHelpPanel sharedHelpPanel];
    }
  NS_HANDLER
    {
      panel = nil;
    }
  NS_ENDHANDLER
  if (panel == nil)
    {
      SKIP("the backend is not available")
    }

  PASS([panel helpFile] == nil, "no help file before one is shown");

  [panel showFile: @"/nonexistent-gnustep-help/a.rtf" atMarker: nil];
  PASS_EQUAL([panel helpFile], @"/nonexistent-gnustep-help/a.rtf",
    "the help file shown is kept");

  [NSHelpPanel setHelpDirectory: dir];
  [panel showFile: @"b.rtf" atMarker: nil];
  PASS_EQUAL([panel helpFile], [dir stringByAppendingPathComponent: @"b.rtf"],
    "a relative help file is kept with the help directory");

  [NSHelpPanel attachHelpFile: @"/nonexistent-gnustep-help/c.rtf"
                   markerName: nil
                           to: panel];
  PASS_EQUAL([panel helpFile], [dir stringByAppendingPathComponent: @"b.rtf"],
    "attaching a help file to an object does not change the file shown");
  [NSHelpPanel detachHelpFrom: panel];

  END_SET("NSHelpPanel helpFile")

  [pool release];
  return 0;
}
