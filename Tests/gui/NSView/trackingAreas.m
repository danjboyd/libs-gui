/* A tracking area sends its owner mouseEntered: and mouseExited: as the mouse
   crosses it.  The events go through the window, as real mouse moves do. */
#import "Testing.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSResponder.h>
#import <AppKit/NSTrackingArea.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

@interface Owner : NSResponder
{
@public
  int entered;
  int exited;
}
@end

@implementation Owner
- (void) mouseEntered: (NSEvent *)e
{
  entered++;
}
- (void) mouseExited: (NSEvent *)e
{
  exited++;
}
@end

@interface Counting : NSView
{
@public
  int updates;
}
@end

@implementation Counting
- (void) updateTrackingAreas
{
  updates++;
  [super updateTrackingAreas];
}
@end

static void
moveTo(NSWindow *w, NSPoint p)
{
  [w sendEvent: [NSEvent mouseEventWithType: NSMouseMoved
                                   location: p
                              modifierFlags: 0
                                  timestamp: 0
                               windowNumber: [w windowNumber]
                                    context: nil
                                eventNumber: 0
                                 clickCount: 0
                                   pressure: 0]];
}

int
main(int argc, char **argv)
{
  START_SET("NSView tracking areas")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w;
      Counting *v;
      Owner *owner = AUTORELEASE([Owner new]);
      NSTrackingArea *area;
      NSPoint outside;
      NSPoint inside;

      w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 200, 200)
                  styleMask: NSTitledWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      v = AUTORELEASE([[Counting alloc]
        initWithFrame: NSMakeRect(50, 50, 100, 100)]);
      [[w contentView] addSubview: v];
      [w orderFront: nil];
      [w setAcceptsMouseMovedEvents: YES];

      PASS([[v trackingAreas] count] == 0, "a view starts with no tracking areas");

      area = AUTORELEASE([[NSTrackingArea alloc]
        initWithRect: NSMakeRect(0, 0, 100, 100)
             options: NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
               owner: owner
            userInfo: nil]);
      [v addTrackingArea: area];
      PASS([[v trackingAreas] count] == 1
        && [[v trackingAreas] objectAtIndex: 0] == area, "the area is added");
      [v addTrackingArea: area];
      PASS([[v trackingAreas] count] == 1, "adding it again changes nothing");

      outside = NSMakePoint(10, 10);
      inside = NSMakePoint(100, 100);
      moveTo(w, outside);
      moveTo(w, inside);
      PASS(owner->entered == 1, "moving in sends mouseEntered: to the owner");
      moveTo(w, outside);
      PASS(owner->exited == 1, "moving out sends mouseExited: to the owner");

      [v removeTrackingArea: area];
      PASS([[v trackingAreas] count] == 0, "the area is removed");
      moveTo(w, inside);
      moveTo(w, outside);
      PASS(owner->entered == 1 && owner->exited == 1,
        "a removed area sends nothing");

      v->updates = 0;
      [v setFrameSize: NSMakeSize(90, 90)];
      PASS(v->updates == 1, "a change of size calls updateTrackingAreas");
      [w orderOut: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSView tracking areas")

  return 0;
}
