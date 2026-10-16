/* -trackMouse:inRect:ofView:untilMouseUp: sends
   -stopTracking:at:inView:mouseIsUp: the point where the mouse went up,
   with the last dragged point before it.  It used to pass the last dragged
   point, since the loop stopped at the mouse-up before reading where it
   was.  With untilMouseUp YES the answer is YES wherever the mouse went
   up.  A mouse-down sent straight to a view, as a test or a browser
   probe does, leaves an older mouse-up as the application's current
   event; tracking ends at it, as before, without taking its location.
   The events need a window, so the set is skipped when the backend is
   unavailable. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

@interface TrackingCell : NSCell
{
@public
  BOOL stopped;
  BOOL mouseIsUp;
  NSPoint lastPoint;
  NSPoint stopPoint;
}
@end

@implementation TrackingCell
- (BOOL) startTrackingAt: (NSPoint)p inView: (NSView *)v
{
  return YES;
}
- (BOOL) continueTracking: (NSPoint)last at: (NSPoint)p inView: (NSView *)v
{
  return YES;
}
- (void) stopTracking: (NSPoint)last
                   at: (NSPoint)p
               inView: (NSView *)v
            mouseIsUp: (BOOL)up
{
  stopped = YES;
  lastPoint = last;
  stopPoint = p;
  mouseIsUp = up;
}
@end

static NSEvent *
mouse(NSEventType type, NSWindow *w, CGFloat x, CGFloat y)
{
  return [NSEvent mouseEventWithType: type
                            location: NSMakePoint(x, y)
                       modifierFlags: 0
                           timestamp: 0.0
                        windowNumber: [w windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 1.0];
}

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSView *view;
  TrackingCell *cell;
  NSEvent *down;
  BOOL inside;

  START_SET("NSCell trackMouseStopPoint")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 200, 100)
              styleMask: NSBorderlessWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  view = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  [window setContentView: view];
  cell = AUTORELEASE([[TrackingCell alloc] initTextCell: @"cell"]);

  /* Make the press the current event, then queue a drag and a release
     outside the cell's frame. */
  [NSApp postEvent: mouse(NSLeftMouseDown, window, 10, 10) atStart: NO];
  down = [NSApp nextEventMatchingMask: NSLeftMouseDownMask
                            untilDate: [NSDate distantFuture]
                               inMode: NSEventTrackingRunLoopMode
                              dequeue: YES];
  [NSApp postEvent: mouse(NSLeftMouseDragged, window, 20, 20) atStart: NO];
  [NSApp postEvent: mouse(NSLeftMouseUp, window, 150, 25) atStart: NO];

  inside = [cell trackMouse: down
                     inRect: NSMakeRect(0, 0, 100, 100)
                     ofView: view
               untilMouseUp: YES];

  PASS(cell->stopped && cell->mouseIsUp,
       "tracking stops with the mouse up");
  PASS(NSEqualPoints(cell->stopPoint, NSMakePoint(150, 25)),
       "the stop point is where the mouse went up");
  PASS(NSEqualPoints(cell->lastPoint, NSMakePoint(20, 20)),
       "the last point is the last dragged point");
  PASS(inside == YES,
       "with untilMouseUp YES, tracking answers YES wherever the mouse went up");

  /* The release above, outside the cell, is now the current event.  Track
     a press that never became the current event, with its own release
     queued at the same point, as a probe sending the press straight to a
     view does. */
  cell->stopped = NO;
  [NSApp postEvent: mouse(NSLeftMouseUp, window, 50, 50) atStart: NO];
  inside = [cell trackMouse: mouse(NSLeftMouseDown, window, 50, 50)
                     inRect: NSMakeRect(0, 0, 100, 100)
                     ofView: view
               untilMouseUp: NO];
  PASS(inside == YES,
       "a press sent straight to the view goes up inside the cell");
  PASS(cell->stopped && NSEqualPoints(cell->stopPoint, NSMakePoint(50, 50)),
       "an older mouse-up does not move the stop point");
  [NSApp nextEventMatchingMask: NSLeftMouseUpMask
                     untilDate: [NSDate distantPast]
                        inMode: NSEventTrackingRunLoopMode
                       dequeue: YES];

  END_SET("NSCell trackMouseStopPoint")

  [pool release];
  return 0;
}
