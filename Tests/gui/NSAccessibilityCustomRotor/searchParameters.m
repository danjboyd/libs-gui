/* NSAccessibilityCustomRotorSearchParameters exists and keeps what it is
   given.  The header only forward-declared the class, so the required
   method of NSAccessibilityCustomRotorItemSearchDelegate named a class
   that had no interface, and Swift could not import the requirement.
   Search parameters need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>
#include <AppKit/NSAccessibilityCustomRotor.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSAccessibilityCustomRotorSearchParameters *p;
  NSAccessibilityCustomRotorItemResult *item;
  NSMutableString *filter = [NSMutableString stringWithString: @"abc"];

  START_SET("NSAccessibilityCustomRotorSearchParameters")

  p = AUTORELEASE([[NSAccessibilityCustomRotorSearchParameters alloc] init]);
  PASS(p != nil, "search parameters can be made");
  PASS([p currentItem] == nil, "there is no current item at first");
  PASS_EQUAL([p filterString], @"", "the filter string is empty at first");

  item = AUTORELEASE([[NSAccessibilityCustomRotorItemResult alloc]
    initWithTargetElement: nil]);
  [p setCurrentItem: item];
  PASS([p currentItem] == item, "the current item is kept");

  [p setSearchDirection: NSAccessibilityCustomRotorSearchDirectionPrevious];
  PASS([p searchDirection] == NSAccessibilityCustomRotorSearchDirectionPrevious,
    "the previous direction is kept");
  [p setSearchDirection: NSAccessibilityCustomRotorSearchDirectionNext];
  PASS([p searchDirection] == NSAccessibilityCustomRotorSearchDirectionNext,
    "the next direction is kept");

  [p setFilterString: filter];
  [filter appendString: @"d"];
  PASS_EQUAL([p filterString], @"abc", "the filter string is copied");

  END_SET("NSAccessibilityCustomRotorSearchParameters")

  [pool release];
  return 0;
}
