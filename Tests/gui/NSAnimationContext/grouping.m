/* NSAnimationContext keeps a stack of contexts per thread: +currentContext
   answers the context of the innermost grouping, +endGrouping arranges
   for the completion handler of the grouping it ends to be called, and
   +runAnimationGroup:completionHandler: runs the changes block with the
   context of a new grouping, then the completion handler.  These were
   empty stubs: +currentContext answered nil and neither block was run.
   GNUstep does not animate, so a handler is called at once when the
   duration is zero, and from the run loop once the duration has passed
   otherwise, as Cocoa calls it when the animations finish. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDate.h>
#include <Foundation/NSRunLoop.h>

#include <AppKit/NSAnimationContext.h>

#if __has_feature(blocks)
static int	repeats = 0;

/* Starts a grouping whose completion handler starts the next one, as a
   repeating animation does, three times in all. */
static void
repeatGroup(NSTimeInterval duration)
{
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
      [context setDuration: duration];
    }
    completionHandler: ^{
      repeats++;
      if (repeats < 3)
	{
	  repeatGroup(duration);
	}
    }];
}

/* Runs the current run loop until the condition holds or a second has
   passed. */
static void
spin(BOOL (^condition)(void))
{
  NSDate	*limit = [NSDate dateWithTimeIntervalSinceNow: 1.0];

  while (!condition() && [limit timeIntervalSinceNow] > 0)
    {
      [[NSRunLoop currentRunLoop]
	runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.01]];
    }
}
#endif

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSAnimationContext grouping")

#if __has_feature(blocks)
  NSAnimationContext	*outer;
  NSAnimationContext	*inner;
  __block NSAnimationContext	*seen = nil;
  __block int		changes = 0;
  __block int		completions = 0;
  __block int		changesAtCompletion = -1;

  outer = [NSAnimationContext currentContext];
  PASS(outer != nil, "there is a current context outside any grouping");
  PASS([NSAnimationContext currentContext] == outer,
    "the context outside any grouping stays the same");

  [NSAnimationContext beginGrouping];
  inner = [NSAnimationContext currentContext];
  PASS(inner != nil && inner != outer,
    "a grouping has its own current context");
  PASS([inner duration] == 0.25, "a grouping lasts 0.25 seconds by default");
  [inner setDuration: 0.0];
  [inner setCompletionHandler: ^{ completions++; }];
  [NSAnimationContext endGrouping];
  PASS(completions == 1,
    "ending a grouping without duration calls its completion handler");
  PASS([NSAnimationContext currentContext] == outer,
    "ending a grouping restores the outer context");
  PASS([outer duration] == 0.25, "the outer context keeps its duration");

  completions = 0;
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
      seen = context;
      [context setDuration: 0.0];
      changes++;
    }
    completionHandler: ^{
      changesAtCompletion = changes;
      completions++;
    }];
  PASS(changes == 1, "the changes block runs once");
  PASS(seen != nil && seen != outer,
    "the changes block gets the context of a new grouping");
  PASS(completions == 1, "the completion handler runs once");
  PASS(changesAtCompletion == 1,
    "the completion handler runs after the changes");
  PASS([NSAnimationContext currentContext] == outer,
    "running a group restores the outer context");

  completions = 0;
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
      changes++;
      [context setDuration: 0.0];
    }
    completionHandler: NULL];
  PASS(changes == 2 && completions == 0,
    "a group runs without a completion handler");

  completions = 0;
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
      [context setDuration: 0.1];
    }
    completionHandler: ^{ completions++; }];
  PASS(completions == 0,
    "a group with a duration does not call its handler at once");
  spin(^{ return (BOOL)(completions > 0); });
  PASS(completions == 1,
    "a group with a duration calls its handler from the run loop");

  repeats = 0;
  repeatGroup(0.0);
  PASS(repeats == 3, "a handler can start the next group");

  repeats = 0;
  repeatGroup(0.05);
  PASS(repeats == 0, "a repeating group with a duration does not recurse");
  spin(^{ return (BOOL)(repeats >= 3); });
  PASS(repeats == 3, "a repeating group with a duration repeats");
  PASS([NSAnimationContext currentContext] == outer,
    "repeated groups restore the outer context");
#else
  SKIP("the compiler does not support blocks")
#endif

  END_SET("NSAnimationContext grouping")

  [pool release];
  return 0;
}
