/* A drag destination is asked -wantsPeriodicDraggingUpdates when a drag
   enters it, and answering NO does not stop it receiving the drop.  The
   drag is made of queued mouse events.  The windows need the backend, so
   the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSDragging.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

static BOOL
samePoint(NSPoint a, NSPoint b)
{
  return fabs(a.x - b.x) < 0.5 && fabs(a.y - b.y) < 0.5;
}

static NSEvent *
mouseEvent(NSEventType type, NSWindow *window, NSPoint point)
{
  return [NSEvent mouseEventWithType: type
                            location: point
                       modifierFlags: 0
                           timestamp: 0
                        windowNumber: [window windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 1.0];
}

@interface PeriodicSource : NSView
@end

@implementation PeriodicSource
- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL)flag
{
  return NSDragOperationCopy;
}
@end

@interface PeriodicDestination : NSView
{
@public
  int entered;
  int queries;
  int performed;
}
@end

@implementation PeriodicDestination
- (NSDragOperation) draggingEntered: (id <NSDraggingInfo>)sender
{
  entered++;
  return NSDragOperationCopy;
}
- (NSDragOperation) draggingUpdated: (id <NSDraggingInfo>)sender
{
  return NSDragOperationCopy;
}
- (BOOL) wantsPeriodicDraggingUpdates
{
  queries++;
  return NO;
}
- (BOOL) performDragOperation: (id <NSDraggingInfo>)sender
{
  performed++;
  return YES;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSDragging wantsPeriodicDraggingUpdates")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 300, 200, 150)
                  styleMask: NSBorderlessWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSView *content = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 150)]);
      PeriodicSource *source = AUTORELEASE([[PeriodicSource alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 150)]);
      PeriodicDestination *dest = AUTORELEASE([[PeriodicDestination alloc]
        initWithFrame: NSMakeRect(100, 0, 100, 150)]);
      NSImage *image = AUTORELEASE([[NSImage alloc]
        initWithSize: NSMakeSize(8, 8)]);
      NSPasteboard *pboard = [NSPasteboard pasteboardWithName: NSDragPboard];
      NSPoint down = NSMakePoint(20, 30);
      NSPoint up = NSMakePoint(150, 50);
      int i;

      [w setReleasedWhenClosed: NO];
      [content addSubview: source];
      [content addSubview: dest];
      [w setContentView: content];
      [dest registerForDraggedTypes:
        [NSArray arrayWithObject: NSStringPboardType]];
      [w orderFront: nil];
      for (i = 0; i < 5; i++)
        {
          [[NSRunLoop currentRunLoop] runUntilDate:
            [NSDate dateWithTimeIntervalSinceNow: 0.02]];
        }

      [pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType]
                     owner: nil];
      [pboard setString: @"periodic" forType: NSStringPboardType];

      [NSApp postEvent: mouseEvent(NSLeftMouseDragged, w, up) atStart: NO];
      [NSApp postEvent: mouseEvent(NSLeftMouseUp, w, up) atStart: NO];
      [source dragImage: image
                     at: down
                 offset: NSMakeSize(0, 0)
                  event: mouseEvent(NSLeftMouseDown, w, down)
             pasteboard: pboard
                 source: source
              slideBack: NO];

      PASS(dest->entered == 1, "the drag enters the destination");
      PASS(dest->queries >= 1,
        "the destination is asked whether it wants periodic updates");
      PASS(dest->performed == 1,
        "a destination that wants no periodic updates still gets the drop");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSDragging wantsPeriodicDraggingUpdates")

  DESTROY(arp);
  return 0;
}
