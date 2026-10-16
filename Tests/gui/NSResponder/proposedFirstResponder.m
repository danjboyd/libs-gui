/* A click asks the clicked view validateProposedFirstResponder:forEvent:
   before making it first responder, and a view asks its superview, so a
   container can refuse first responder status for the views it holds;
   the clicked view still gets the mouse down.  Nothing asked, and NSView
   answered YES without asking its superview.  The window needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

@interface Container : NSView
{
@public
  BOOL refuses;
  int asked;
}
@end

@implementation Container
- (BOOL) validateProposedFirstResponder: (NSResponder *)responder
                               forEvent: (NSEvent *)event
{
  asked++;
  return refuses ? NO : [super validateProposedFirstResponder: responder
                                                     forEvent: event];
}
@end

@interface Focus : NSView
{
@public
  int downs;
}
@end

@implementation Focus
- (BOOL) acceptsFirstResponder
{
  return YES;
}
- (void) mouseDown: (NSEvent *)event
{
  downs++;
}
@end

static NSEvent *
click(NSWindow *w)
{
  return [NSEvent mouseEventWithType: NSLeftMouseDown
                            location: NSMakePoint(50, 90)
                       modifierFlags: 0
                           timestamp: 0
                        windowNumber: [w windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 1.0];
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSResponder proposed first responder")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 240, 180)
                  styleMask: NSTitledWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      Container *container = AUTORELEASE([[Container alloc]
        initWithFrame: NSMakeRect(10, 60, 200, 90)]);
      Focus *view = AUTORELEASE([[Focus alloc]
        initWithFrame: NSMakeRect(10, 10, 80, 40)]);
      NSView *other = AUTORELEASE([[Focus alloc]
        initWithFrame: NSMakeRect(150, 10, 20, 20)]);

      [container addSubview: view];
      [[w contentView] addSubview: container];
      [[w contentView] addSubview: other];
      [w makeKeyAndOrderFront: nil];

      container->refuses = YES;
      PASS([view validateProposedFirstResponder: view forEvent: nil] == NO
        && container->asked == 1,
        "a view asks its superview");
      PASS([other validateProposedFirstResponder: other forEvent: nil],
        "a view whose superviews do not refuse is valid");

      [w makeFirstResponder: other];
      container->asked = 0;
      [w sendEvent: click(w)];
      PASS(container->asked == 1 && [w firstResponder] == other,
        "a click does not make a refused view first responder");
      PASS(view->downs == 1, "the refused view still gets the mouse down");

      container->refuses = NO;
      [w sendEvent: click(w)];
      PASS([w firstResponder] == view,
        "a click makes a valid view first responder");
      [w orderOut: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSResponder proposed first responder")

  DESTROY(arp);
  return 0;
}
