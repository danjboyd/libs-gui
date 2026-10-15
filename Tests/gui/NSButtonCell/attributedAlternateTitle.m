/* A button cell keeps the attributes of an attributed alternate title,
   and in a keyed archive.  The setter kept only the string, and the getter
   rebuilt the title with the cell's own text attributes.  The cell's
   default font needs the backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/Foundation.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSAttributedString.h>
#include <AppKit/NSButtonCell.h>
#include <AppKit/NSColor.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSButtonCell *cell;
  NSButtonCell *decoded;
  NSAttributedString *alt;
  NSData *data;

  START_SET("NSButtonCell attributedAlternateTitle")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name]
        isEqualToString: NSInternalInconsistencyException])
        {
          SKIP("It looks like GNUstep backend is not yet installed")
        }
    }
  NS_ENDHANDLER

  alt = AUTORELEASE([[NSAttributedString alloc]
    initWithString: @"Off"
        attributes: [NSDictionary dictionaryWithObject: [NSColor redColor]
                                                forKey: NSForegroundColorAttributeName]]);
  cell = AUTORELEASE([[NSButtonCell alloc] initTextCell: @"On"]);
  [cell setAttributedAlternateTitle: alt];

  PASS_EQUAL([cell attributedAlternateTitle], alt,
    "the attributed alternate title keeps its attributes");
  PASS_EQUAL([cell alternateTitle], @"Off",
    "the alternate title is its string");

  data = [NSKeyedArchiver archivedDataWithRootObject: cell];
  decoded = [NSKeyedUnarchiver unarchiveObjectWithData: data];
  PASS_EQUAL([decoded attributedAlternateTitle], alt,
    "the attributed alternate title survives a keyed archive");

  [cell setAlternateTitle: @"Plain"];
  PASS_EQUAL([cell alternateTitle], @"Plain",
    "a plain alternate title replaces the attributed one");
  PASS([[cell attributedAlternateTitle]
    attribute: NSForegroundColorAttributeName atIndex: 0 effectiveRange: NULL]
    != [NSColor redColor],
    "and drops its attributes");

  END_SET("NSButtonCell attributedAlternateTitle")

  [pool release];
  return 0;
}
