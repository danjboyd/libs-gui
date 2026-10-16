/* An NSSplitView asks its delegate for an additional area that grabs a
   divider, splitView:additionalEffectiveRectOfDividerAtIndex:, and
   whether to hide a divider, splitView:shouldHideDividerAtIndex:.  A
   press in the additional area drags the divider, which moves as far as
   the mouse does; a hidden divider is not drawn and can be dragged only
   by its additional area.  Neither method used to be sent.  The divider
   is dragged with queued mouse events.  The split view needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSSplitView.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

@interface CountingSplitView : NSSplitView
{
@public
  int drawn;
}
@end

@implementation CountingSplitView
- (void) drawDividerInRect: (NSRect)aRect
{
  drawn++;
  [super drawDividerInRect: aRect];
}
@end

@interface DividerDelegate : NSObject
{
@public
  NSRect extra;
  BOOL hides;
  int extraAsked;
  int hideAsked;
}
@end

@implementation DividerDelegate
- (NSRect) splitView: (NSSplitView *)splitView
additionalEffectiveRectOfDividerAtIndex: (NSInteger)dividerIndex
{
  extraAsked++;
  return extra;
}
- (BOOL) splitView: (NSSplitView *)splitView
shouldHideDividerAtIndex: (NSInteger)dividerIndex
{
  hideAsked++;
  return hides;
}
@end

static CountingSplitView *split;
static NSView *left;
static NSView *right;
static CGFloat thickness;

static NSEvent *
mouseEvent(NSEventType type, NSPoint p)
{
  return [NSEvent mouseEventWithType: type
                            location: p
                       modifierFlags: 0
                           timestamp: 0
                        windowNumber: [[split window] windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 1.0];
}

static void
reset(id delegate)
{
  [split setDelegate: nil];
  [left setFrame: NSMakeRect(0, 0, 100, 40)];
  [right setFrame: NSMakeRect(100 + thickness, 0, 200 - thickness, 40)];
  [split setDelegate: delegate];
}

/* Presses at from, drags to to and releases, in split view coordinates,
   and answers where the divider's center ends. */
static CGFloat
drag(CGFloat from, CGFloat to)
{
  NSPoint press = [split convertPoint: NSMakePoint(from, 20) toView: nil];
  NSPoint target = [split convertPoint: NSMakePoint(to, 20) toView: nil];

  while ([NSApp nextEventMatchingMask: NSAnyEventMask
                            untilDate: [NSDate distantPast]
                               inMode: NSDefaultRunLoopMode
                              dequeue: YES] != nil)
    ;
  [NSApp postEvent: mouseEvent(NSLeftMouseDragged, target) atStart: NO];
  [NSApp postEvent: mouseEvent(NSLeftMouseUp, target) atStart: NO];
  [split mouseDown: mouseEvent(NSLeftMouseDown, press)];
  return NSMaxX([left frame]) + thickness / 2;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSSplitView divider delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 320, 80)
                  styleMask: NSBorderlessWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      DividerDelegate *delegate = AUTORELEASE([DividerDelegate new]);

      split = AUTORELEASE([[CountingSplitView alloc]
        initWithFrame: NSMakeRect(10, 20, 300, 40)]);
      left = AUTORELEASE([[NSView alloc] initWithFrame: NSZeroRect]);
      right = AUTORELEASE([[NSView alloc] initWithFrame: NSZeroRect]);
      [split setVertical: YES];
      [split addSubview: left];
      [split addSubview: right];
      [[w contentView] addSubview: split];
      [w orderFront: nil];
      thickness = [split dividerThickness];

      reset(nil);
      PASS(fabs(drag(170, 220) - (100 + thickness / 2)) < 1,
        "a press inside a subview does not drag the divider");

      delegate->extra = NSMakeRect(160, 0, 20, 40);
      reset(delegate);
      PASS(fabs(drag(170, 220) - 150) < 1 && delegate->extraAsked > 0,
        "a press in the delegate's additional area drags the divider");

      reset(delegate);
      split->drawn = 0;
      [split display];
      PASS(split->drawn == 1 && delegate->hideAsked > 0,
        "a divider the delegate does not hide is drawn");

      delegate->hides = YES;
      reset(delegate);
      split->drawn = 0;
      [split display];
      PASS(split->drawn == 0, "a hidden divider is not drawn");
      PASS(fabs(drag(100 + thickness / 2, 160) - (100 + thickness / 2)) < 1,
        "a hidden divider cannot be dragged by itself");
      reset(delegate);
      PASS(fabs(drag(170, 220) - 150) < 1,
        "a hidden divider is dragged by its additional area");
      [w orderOut: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSSplitView divider delegate")

  DESTROY(arp);
  return 0;
}
