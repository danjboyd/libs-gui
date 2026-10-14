/* The completion handler of an animation context is a copy property, so
   the context keeps its own copy of the block.  It used to store the
   caller's block pointer, which dangled once a stack block went out of
   scope or the caller released its block.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSAnimationContext.h>

#if __has_feature(blocks)
static void
setHandler(NSAnimationContext *context, int *counter)
{
  int	step = 2;

  /* A block capturing a local variable starts out on the stack.  */
  [context setCompletionHandler: ^{ *counter += step; }];
}
#endif

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSAnimationContext completionHandler")

#if __has_feature(blocks)
  NSAnimationContext	*context;
  int			counter = 0;

  context = AUTORELEASE([NSAnimationContext new]);
  PASS([context completionHandler] == NULL,
    "a new context has no completion handler");

  setHandler(context, &counter);
  PASS([context completionHandler] != NULL,
    "the context has a completion handler once one is set");
  [context completionHandler]();
  PASS(counter == 2,
    "the completion handler outlives the scope of the block it was set to");

  [context setCompletionHandler: NULL];
  PASS([context completionHandler] == NULL,
    "the completion handler can be cleared");
#else
  SKIP("the compiler does not support blocks")
#endif

  END_SET("NSAnimationContext completionHandler")

  [pool release];
  return 0;
}
