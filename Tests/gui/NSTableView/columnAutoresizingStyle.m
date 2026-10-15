/* A table view keeps its column autoresizing style, and the uniform style
   is the one autoresizesAllColumnsToFit stands for, and keyed archives
   keep it, under the key Cocoa archives use.  The setter was a stub,
   so the style always read as no autoresizing.  The table view needs the
   backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSTableView.h>
#include <Foundation/NSKeyedArchiver.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTableView *tv;

  START_SET("NSTableView columnAutoresizingStyle")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)]);
  [tv setColumnAutoresizingStyle: NSTableViewUniformColumnAutoresizingStyle];
  PASS([tv columnAutoresizingStyle] == NSTableViewUniformColumnAutoresizingStyle,
    "the uniform style is kept");
  PASS([tv autoresizesAllColumnsToFit], "the uniform style resizes all columns");

  [tv setColumnAutoresizingStyle: NSTableViewLastColumnOnlyAutoresizingStyle];
  PASS([tv columnAutoresizingStyle] == NSTableViewLastColumnOnlyAutoresizingStyle
    && ![tv autoresizesAllColumnsToFit],
    "another style is kept and does not resize all columns");

  [tv setAutoresizesAllColumnsToFit: YES];
  PASS([tv columnAutoresizingStyle] == NSTableViewUniformColumnAutoresizingStyle,
    "resizing all columns is the uniform style");

  {
    NSTableView *decoded;

    [tv setColumnAutoresizingStyle: NSTableViewReverseSequentialColumnAutoresizingStyle];
    decoded = [NSKeyedUnarchiver unarchiveObjectWithData:
      [NSKeyedArchiver archivedDataWithRootObject: tv]];
    PASS([decoded columnAutoresizingStyle]
      == NSTableViewReverseSequentialColumnAutoresizingStyle,
      "keyed archiving keeps the style");
  }

  END_SET("NSTableView columnAutoresizingStyle")

  [pool release];
  return 0;
}
