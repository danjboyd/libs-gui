/* -[NSTextStorage attributeRuns] answers one text storage for each run of
   characters with the same attributes, with those attributes.  It
   answered an empty array.  The attributes here are plain strings, but
   text storage may fix fonts, so the set keeps the usual backend
   guard. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTextStorage.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTextStorage *ts;
  NSArray *runs;
  NSDictionary *bold = [NSDictionary dictionaryWithObject: @"b"
                                                   forKey: @"GSTestKey"];

  START_SET("NSTextStorage attributeRuns")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  ts = AUTORELEASE([[NSTextStorage alloc] initWithString: @"aaBBBcc"]);
  [ts addAttributes: bold range: NSMakeRange(2, 3)];

  runs = [ts attributeRuns];
  PASS([runs count] == 3, "there is one run per attribute change");
  PASS_EQUAL([[runs objectAtIndex: 0] string], @"aa", "the first run");
  PASS_EQUAL([[runs objectAtIndex: 1] string], @"BBB", "the second run");
  PASS_EQUAL([[runs objectAtIndex: 2] string], @"cc", "the third run");
  PASS_EQUAL([[runs objectAtIndex: 1] attribute: @"GSTestKey"
                                        atIndex: 0
                                 effectiveRange: NULL], @"b",
    "a run keeps its attributes");

  ts = AUTORELEASE([[NSTextStorage alloc] initWithString: @""]);
  PASS([[ts attributeRuns] count] == 0, "empty text has no runs");

  END_SET("NSTextStorage attributeRuns")

  [pool release];
  return 0;
}
