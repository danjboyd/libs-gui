/* The lower-roman and upper-roman marker formats give roman numerals,
 * and a number roman numerals do not cover is given in decimal.  These
 * formats were left in the marker as written.  Text lists need no
 * backend.
 */
#include "Testing.h"
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>
#include <AppKit/NSTextList.h>

static NSString *
marker(NSString *fmt, int item)
{
  NSTextList	*l = [[[NSTextList alloc] initWithMarkerFormat: fmt
						       options: 0] autorelease];
  return [l markerForItemNumber: item];
}

int main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];

  START_SET("NSTextList roman markers")
    PASS_EQUAL(marker(@"{lower-roman}.", 4), @"iv.", "4 is iv");
    PASS_EQUAL(marker(@"{upper-roman}", 9), @"IX", "9 is IX");
    PASS_EQUAL(marker(@"{upper-roman}", 1994), @"MCMXCIV", "1994 is MCMXCIV");
    PASS_EQUAL(marker(@"({lower-roman})", 3999), @"(mmmcmxcix)",
      "3999 is mmmcmxcix");
    PASS_EQUAL(marker(@"{upper-roman}", 0), @"0",
      "0 has no roman numeral and is given in decimal");
  END_SET("NSTextList roman markers")

  [pool release];
  return 0;
}
