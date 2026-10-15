/* An animation made with -init is fully initialized.  NSAnimation had no
   -init of its own, so -init left the progress marks and the lock unset,
   and -dealloc (like -addProgressMark:) dereferenced the missing marks
   array: [[[NSAnimation alloc] init] release] crashed.  -init uses the
   duration and curve -initWithCoder: falls back to, and NSViewAnimation's
   -init the defaults of -initWithViewAnimations:. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>

#include <AppKit/NSAnimation.h>

int main()
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  NSAnimation		*a;
  NSViewAnimation	*v;

  START_SET("NSAnimation init")

  a = [[NSAnimation alloc] init];
  PASS(a != nil, "-init answers an animation");
  PASS([a duration] == 1.0, "-init gives a duration of one second");
  PASS([a animationCurve] == NSAnimationEaseInOut,
    "-init gives the ease in-out curve");
  PASS([a isAnimating] == NO, "an animation made with -init is not animating");
  [a addProgressMark: 0.5];
  PASS([[a progressMarks] count] == 1,
    "an animation made with -init takes progress marks");
  [a release];
  PASS(YES, "an animation made with -init can be released");

  a = [NSAnimation new];
  [a release];
  PASS(YES, "an animation made with +new can be released");

  v = [[NSViewAnimation alloc] init];
  PASS(v != nil && [v viewAnimations] == nil,
    "-init answers a view animation without view animations");
  PASS([v duration] == 0.5
    && [v animationBlockingMode] == NSAnimationNonblocking,
    "-init gives a view animation the defaults of -initWithViewAnimations:");
  [v release];
  PASS(YES, "a view animation made with -init can be released");

  END_SET("NSAnimation init")

  [pool release];
  return 0;
}
