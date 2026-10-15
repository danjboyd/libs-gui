/* An event posted while the run loop waits is seen at once: from a timer
 * in the mode being run, from another thread, and at the start of the
 * queue while a scan for some kinds of event is under way.  -abortModal
 * from a timer ends -runModalForWindow: without the caller posting an
 * event, and leaves no event behind.  Needs the backend, so the set is
 * skipped without it.
 */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSPanel.h>

static NSEvent *
appEvent(short subtype)
{
  return [NSEvent otherEventWithType: NSApplicationDefined
			    location: NSZeroPoint
		       modifierFlags: 0
			   timestamp: 0
			windowNumber: 0
			     context: nil
			     subtype: subtype
			       data1: 0
			       data2: 0];
}

@interface Poster : NSObject
@end

@implementation Poster
- (void) post: (NSTimer *)t
{
  [NSApp postEvent: appEvent(1) atStart: NO];
}
- (void) postAtStart: (NSTimer *)t
{
  [NSApp postEvent: appEvent(2) atStart: YES];
}
- (void) abort: (NSTimer *)t
{
  [NSApp abortModal];
}
- (void) fromThread: (id)ignored
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];

  [NSThread sleepForTimeInterval: 0.1];
  [NSApp postEvent: appEvent(3) atStart: NO];
  [pool release];
}
@end

static void
after(NSTimeInterval delay, id target, SEL sel, NSString *mode)
{
  [[NSRunLoop currentRunLoop]
    addTimer: [NSTimer timerWithTimeInterval: delay
				      target: target
				    selector: sel
				    userInfo: nil
				     repeats: NO]
     forMode: mode];
}

static NSEvent *
waitFor(NSUInteger mask, NSTimeInterval limit, NSString *mode,
  NSTimeInterval *took)
{
  NSDate	*start = [NSDate date];
  NSEvent	*e;

  e = [NSApp nextEventMatchingMask: mask
			 untilDate: [NSDate dateWithTimeIntervalSinceNow: limit]
			    inMode: mode
			   dequeue: YES];
  *took = -[start timeIntervalSinceNow];
  return e;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  Poster		*p;
  NSEvent		*e;
  NSTimeInterval	t;

  START_SET("NSApplication postEvent wakes the run loop")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  p = AUTORELEASE([Poster new]);

  /* Clear anything the application start-up posted. */
  while ((e = waitFor(NSAnyEventMask, 0.2, NSDefaultRunLoopMode, &t)) != nil)
    ;

  after(0.1, p, @selector(post:), NSDefaultRunLoopMode);
  e = waitFor(NSAnyEventMask, 5.0, NSDefaultRunLoopMode, &t);
  PASS(e != nil && [e subtype] == 1 && t < 1.0,
    "an event posted from a timer is seen at once in the default mode");

  after(0.1, p, @selector(post:), NSModalPanelRunLoopMode);
  e = waitFor(NSAnyEventMask, 5.0, NSModalPanelRunLoopMode, &t);
  PASS(e != nil && [e subtype] == 1 && t < 1.0,
    "an event posted from a timer is seen at once in the modal panel mode");

  e = waitFor(NSAnyEventMask, 0.2, NSDefaultRunLoopMode, &t);
  PASS(e == nil && t >= 0.15,
    "with nothing posted the loop waits until the date");

  [NSThread detachNewThreadSelector: @selector(fromThread:)
			   toTarget: p
			 withObject: nil];
  e = waitFor(NSAnyEventMask, 5.0, NSDefaultRunLoopMode, &t);
  PASS(e != nil && [e subtype] == 3 && t < 1.0,
    "an event posted from another thread is seen at once");

  /* An event of another kind is in the queue, so a scan for
     application defined events has passed its start. */
  [NSApp postEvent: [NSEvent otherEventWithType: NSPeriodic
				       location: NSZeroPoint
				  modifierFlags: 0
				      timestamp: 0
				   windowNumber: 0
					context: nil
					subtype: 0
					  data1: 0
					  data2: 0]
	   atStart: NO];
  after(0.1, p, @selector(postAtStart:), NSDefaultRunLoopMode);
  e = waitFor(NSApplicationDefinedMask, 5.0, NSDefaultRunLoopMode, &t);
  PASS(e != nil && [e subtype] == 2 && t < 1.0,
    "an event posted at the start of the queue is found by a scan under way");
  e = waitFor(NSPeriodicMask, 0.2, NSDefaultRunLoopMode, &t);
  PASS(e != nil, "the other event is still queued");

  NS_DURING
    {
      NSPanel	*panel = AUTORELEASE([[NSPanel alloc]
	initWithContentRect: NSMakeRect(0, 0, 100, 100)
		  styleMask: NSTitledWindowMask
		    backing: NSBackingStoreBuffered
		      defer: YES]);
      NSDate	*start = [NSDate date];
      NSInteger	code;

      after(0.1, p, @selector(abort:), NSModalPanelRunLoopMode);
      code = [NSApp runModalForWindow: panel];
      t = -[start timeIntervalSinceNow];
      PASS(code == NSModalResponseAbort && t < 2.0,
	"-abortModal from a timer ends -runModalForWindow: at once");
      e = waitFor(NSAnyEventMask, 0.2, NSDefaultRunLoopMode, &t);
      PASS(e == nil, "-abortModal leaves no event in the queue");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSApplication postEvent wakes the run loop")
  [pool release];
  return 0;
}
