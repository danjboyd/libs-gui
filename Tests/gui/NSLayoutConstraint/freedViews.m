/* A view that is freed deactivates the active constraints on it, as in
   Cocoa.  A constraint between two views without a window used to stay
   in NSLayoutConstraint's list of active constraints after its views
   were freed, so the next view moved to a window read the freed views in
   +_installPendingConstraintsForView: and crashed.  The views are freed
   with zombies enabled, so the old behaviour fails the checks instead of
   crashing.  The window needs the backend, so the set is skipped without
   it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSGeometry.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSView.h>
#import <AppKit/NSLayoutConstraint.h>
#import <AppKit/NSLayoutAnchor.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSLayoutConstraint freed views")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 200, 100)
                  styleMask: NSWindowStyleMaskBorderless
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSView *first = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)];
      NSView *second = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)];
      NSView *alone = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)];
      NSView *later = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 10, 10)]);
      NSLayoutConstraint *pair;
      NSLayoutConstraint *single;
      NSAutoreleasePool *inner;

      inner = [NSAutoreleasePool new];
      pair = RETAIN([[first widthAnchor]
        constraintEqualToAnchor: [second widthAnchor]]);
      single = RETAIN([[alone heightAnchor] constraintEqualToConstant: 5.0]);
      [pair setActive: YES];
      [single setActive: YES];
      [inner release];
      PASS([pair isActive] && [single isActive],
        "constraints between views without a window are active");

      NSZombieEnabled = YES;
      [first release];
      PASS([pair isActive] == NO,
        "freeing one of its views deactivates a constraint");
      [second release];
      [alone release];
      PASS([single isActive] == NO,
        "freeing its only view deactivates a constraint");

      [[w contentView] addSubview: later];
      PASS([later window] == w,
        "a view moved to a window after the views were freed is installed");
      NSZombieEnabled = NO;

      RELEASE(pair);
      RELEASE(single);
    }
  NS_HANDLER
    NSZombieEnabled = NO;
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSLayoutConstraint freed views")

  DESTROY(arp);
  return 0;
}
