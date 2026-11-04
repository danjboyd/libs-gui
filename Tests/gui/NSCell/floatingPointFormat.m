/* -setFloatingPointFormat:left:right: builds a formatter from an old style
   format, which only the 10.0 formatter behaviour reads, so the cell's value
   comes out with the number of digits that was asked for. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSNumberFormatter.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTextFieldCell.h>

int
main(int argc, char **argv)
{
  NSTextFieldCell *cell;
  NSNumberFormatter *formatter;

  START_SET("NSCell setFloatingPointFormat")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  cell = AUTORELEASE([[NSTextFieldCell alloc] initTextCell: @""]);
  [cell setFloatingPointFormat: NO left: 3 right: 2];
  formatter = [cell formatter];
  PASS(formatter != nil, "the cell has a formatter");
  PASS([formatter formatterBehavior] == NSNumberFormatterBehavior10_0,
    "the formatter uses the 10.0 behaviour");

  [cell setObjectValue: [NSNumber numberWithDouble: 3.14159]];
  PASS_EQUAL([cell stringValue], @"3.14", "two digits follow the point");
  [cell setFloatingPointFormat: NO left: 3 right: 1];
  [cell setObjectValue: [NSNumber numberWithDouble: 3.14159]];
  PASS_EQUAL([cell stringValue], @"3.1", "the digit count can be changed");

  END_SET("NSCell setFloatingPointFormat")

  return 0;
}
