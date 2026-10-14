/* A click on an NSPathControl records the component under the mouse as the
   clicked component.  The control used to hit-test the mouse location in
   window coordinates against its frame, so in a control away from the
   window origin it recorded the wrong component.  The control needs a
   window, so the set is skipped when the backend is unavailable. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSPathCell.h>
#import <AppKit/NSPathComponentCell.h>
#import <AppKit/NSPathControl.h>
#import <AppKit/NSWindow.h>

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSPathControl *control;
  NSPathComponentCell *a;
  NSPathComponentCell *b;
  NSEvent *event;

  START_SET("NSPathControl clicked component")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 500, 200)
              styleMask: NSBorderlessWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  control = AUTORELEASE([[NSPathControl alloc]
    initWithFrame: NSMakeRect(180, 80, 260, 28)]);
  [[window contentView] addSubview: control];

  a = AUTORELEASE([[NSPathComponentCell alloc] init]);
  b = AUTORELEASE([[NSPathComponentCell alloc] init]);
  [[control cell] setPathComponentCells: [NSArray arrayWithObjects: a, b, nil]];

  event = [NSEvent mouseEventWithType: NSLeftMouseDown
                             location: NSMakePoint(210, 94)
                        modifierFlags: 0
                            timestamp: 0.0
                         windowNumber: [window windowNumber]
                              context: nil
                          eventNumber: 0
                           clickCount: 1
                             pressure: 1.0];
  [control mouseDown: event];
  PASS([[control cell] clickedPathComponentCell] == a,
    "a click in the first component records the first component");

  END_SET("NSPathControl clicked component")

  [pool release];
  return 0;
}
