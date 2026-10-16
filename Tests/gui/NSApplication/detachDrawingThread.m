/* +detachDrawingThread:toTarget:withObject: sends the selector to the
   target in a new thread with the argument it was given.  The argument
   used to be passed by value where its address was expected, so the
   method received a different object. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDate.h>
#include <Foundation/NSLock.h>
#include <Foundation/NSString.h>
#include <Foundation/NSThread.h>

#include <AppKit/NSApplication.h>

@interface DrawingTarget : NSObject
{
@public
  NSCondition *done;
  id received;
  BOOL ran;
  BOOL otherThread;
}
@end

@implementation DrawingTarget
- (void) draw: (id)argument
{
  [done lock];
  received = [argument retain];
  otherThread = ![NSThread isMainThread];
  ran = YES;
  [done signal];
  [done unlock];
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  DrawingTarget *target;
  NSString *argument;
  NSDate *limit;

  START_SET("NSApplication detachDrawingThread")

  target = AUTORELEASE([DrawingTarget new]);
  target->done = AUTORELEASE([NSCondition new]);
  argument = [NSString stringWithFormat: @"argument %d", 42];

  [NSApplication detachDrawingThread: @selector(draw:)
                            toTarget: target
                          withObject: argument];

  limit = [NSDate dateWithTimeIntervalSinceNow: 5.0];
  [target->done lock];
  while (!target->ran && [target->done waitUntilDate: limit])
    ;
  [target->done unlock];

  PASS(target->ran, "the selector is sent");
  PASS(target->otherThread, "the selector is sent in another thread");
  PASS(target->received == argument, "the selector gets the argument");

  END_SET("NSApplication detachDrawingThread")

  DESTROY(arp);
  return 0;
}
