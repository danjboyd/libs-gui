/* The shared all, current and empty selections outlive the autorelease
   pool they were first asked for in.  They were kept without being
   retained, so they were freed when that pool was drained, and the next
   request answered a freed object.  Selections are plain model objects
   and need no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <AppKit/NSSelection.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSAutoreleasePool *inner;
  NSSelection *all;
  NSSelection *current;
  NSSelection *empty;

  START_SET("NSSelection shared selection lifetime")

  inner = [NSAutoreleasePool new];
  all = [NSSelection allSelection];
  current = [NSSelection currentSelection];
  empty = [NSSelection emptySelection];
  [inner release];

  PASS([NSSelection allSelection] == all
    && [all isWellKnownSelection] && [[all descriptionData] length] > 0,
    "the all selection outlives the pool it was made in");
  PASS([NSSelection currentSelection] == current
    && [current isWellKnownSelection] && [[current descriptionData] length] > 0,
    "the current selection outlives the pool it was made in");
  PASS([NSSelection emptySelection] == empty
    && [empty isWellKnownSelection] && [[empty descriptionData] length] > 0,
    "the empty selection outlives the pool it was made in");

  END_SET("NSSelection shared selection lifetime")

  [pool release];
  return 0;
}
