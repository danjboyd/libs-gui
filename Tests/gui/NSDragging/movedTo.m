/* A drag source's draggedImage:movedTo: is given the origin of the
   dragged image in screen coordinates, as draggedImage:beganAt: and
   draggedImage:endedAt:operation: are.  It used to be given the mouse
   location.  The image is dragged from a press 4 points right of and 3
   points above its origin, with queued mouse events.  The windows need
   the backend, so the set is skipped without it. */
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

@interface MoveSource : NSView
{
@public
  NSMutableArray *moved;
  NSPoint began;
  NSPoint ended;
}
@end

@implementation MoveSource
- (void) dealloc
{
  RELEASE(moved);
  [super dealloc];
}
- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL)flag
{
  return NSDragOperationCopy;
}
- (void) draggedImage: (NSImage *)image beganAt: (NSPoint)screenPoint
{
  began = screenPoint;
}
- (void) draggedImage: (NSImage *)image movedTo: (NSPoint)screenPoint
{
  if (moved == nil)
    {
      moved = [NSMutableArray new];
    }
  [moved addObject: [NSValue valueWithPoint: screenPoint]];
}
- (void) draggedImage: (NSImage *)image
              endedAt: (NSPoint)screenPoint
            operation: (NSDragOperation)operation
{
  ended = screenPoint;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSDragging draggedImage:movedTo:")

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
      MoveSource *source = AUTORELEASE([[MoveSource alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 150)]);
      NSImage *image = AUTORELEASE([[NSImage alloc]
        initWithSize: NSMakeSize(16, 16)]);
      NSPasteboard *pboard = [NSPasteboard pasteboardWithName: NSDragPboard];
      NSPoint down = NSMakePoint(20, 30);
      NSPoint imageAt = NSMakePoint(16, 27);
      NSPoint up = NSMakePoint(60, 50);
      NSPoint imageUp;
      int i;

      [w setReleasedWhenClosed: NO];
      [w setContentView: source];
      [w orderFront: nil];
      for (i = 0; i < 5; i++)
        {
          [[NSRunLoop currentRunLoop] runUntilDate:
            [NSDate dateWithTimeIntervalSinceNow: 0.02]];
        }

      [image lockFocus];
      [[NSColor blueColor] set];
      NSRectFill(NSMakeRect(0, 0, 16, 16));
      [image unlockFocus];
      [pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType]
                     owner: nil];
      [pboard setString: @"moved" forType: NSStringPboardType];

      imageUp = [w convertBaseToScreen:
        NSMakePoint(up.x - (down.x - imageAt.x), up.y - (down.y - imageAt.y))];
      [NSApp postEvent: mouseEvent(NSLeftMouseDragged, w, up) atStart: NO];
      [NSApp postEvent: mouseEvent(NSLeftMouseUp, w, up) atStart: NO];
      [source dragImage: image
                     at: imageAt
                 offset: NSMakeSize(0, 0)
                  event: mouseEvent(NSLeftMouseDown, w, down)
             pasteboard: pboard
                 source: source
              slideBack: NO];

      PASS(samePoint(source->began, [w convertBaseToScreen: imageAt]),
        "the source is told where the image began");
      PASS(samePoint(source->ended, imageUp),
        "the source is told the image origin where the drag ended");
      PASS([source->moved count] > 0
        && samePoint([[source->moved lastObject] pointValue], imageUp),
        "the source is told the image origin as the image moves");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSDragging draggedImage:movedTo:")

  DESTROY(arp);
  return 0;
}
