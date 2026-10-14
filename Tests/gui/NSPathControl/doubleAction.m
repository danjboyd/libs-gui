/* The second click of a double click on an NSPathControl sends its double
   action; a single click sends its action.  The click count used to be
   ignored, so the double action was never sent.  The control needs a
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

@interface PathTarget : NSObject
{
@public
  int singles;
  int doubles;
}
@end

@implementation PathTarget
- (void) single: (id)sender
{
  singles++;
}
- (void) twice: (id)sender
{
  doubles++;
}
@end

static NSEvent *
click(NSWindow *window, NSInteger count)
{
  return [NSEvent mouseEventWithType: NSLeftMouseDown
                            location: NSMakePoint(30, 14)
                       modifierFlags: 0
                           timestamp: 0.0
                        windowNumber: [window windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: count
                            pressure: 1.0];
}

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSPathControl *control;
  PathTarget *target;

  START_SET("NSPathControl double action")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 300, 100)
              styleMask: NSBorderlessWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  control = AUTORELEASE([[NSPathControl alloc]
    initWithFrame: NSMakeRect(0, 0, 260, 28)]);
  [[window contentView] addSubview: control];
  [[control cell] setPathComponentCells: [NSArray arrayWithObject:
    AUTORELEASE([[NSPathComponentCell alloc] init])]];

  target = AUTORELEASE([PathTarget new]);
  [control setTarget: target];
  [control setAction: @selector(single:)];
  [control setDoubleAction: @selector(twice:)];

  [control mouseDown: click(window, 1)];
  PASS(target->singles == 1 && target->doubles == 0,
    "a single click sends the action");
  [control mouseDown: click(window, 2)];
  PASS(target->singles == 1 && target->doubles == 1,
    "the second click of a double click sends the double action");

  END_SET("NSPathControl double action")

  [pool release];
  return 0;
}
