/* The all, current and empty selections are shared instances, and each
   decodes as itself.  +allSelection marked the empty selection as the all
   selection, rather than itself, so the all selection decoded as a new
   object, and an empty selection made first decoded as the all selection.
   Selections are plain model objects and need no backend. */
#import "Testing.h"
#import <Foundation/NSArchiver.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSKeyedArchiver.h>
#import <AppKit/NSSelection.h>

static id
keyedRoundTrip(id object)
{
  return [NSKeyedUnarchiver unarchiveObjectWithData:
    [NSKeyedArchiver archivedDataWithRootObject: object]];
}

static id
roundTrip(id object)
{
  return [NSUnarchiver unarchiveObjectWithData:
    [NSArchiver archivedDataWithRootObject: object]];
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSelection *empty;
  NSSelection *all;

  START_SET("NSSelection well known selections")

  /* Make the empty selection first, as the bug marked it.  */
  empty = [NSSelection emptySelection];
  all = [NSSelection allSelection];

  PASS(empty != all, "the all and empty selections differ");
  PASS(keyedRoundTrip(empty) == empty,
    "the empty selection decodes as itself (keyed)");
  PASS(keyedRoundTrip(all) == all,
    "the all selection decodes as itself (keyed)");
  PASS(roundTrip(empty) == empty,
    "the empty selection decodes as itself");
  PASS(roundTrip(all) == all,
    "the all selection decodes as itself");

  END_SET("NSSelection well known selections")

  [pool release];
  return 0;
}
