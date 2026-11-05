/* A new constant on an installed constraint drives the next layout pass, and
 * the layout engine stops watching a constraint it no longer has.
 */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSView.h>
#import <AppKit/NSLayoutConstraint.h>
#import <AppKit/NSLayoutAnchor.h>

int
main(int argc, const char **argv)
{
  START_SET("NSLayoutConstraint constant relayout")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 300, 200)
                  styleMask: NSWindowStyleMaskBorderless
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSView *content = [w contentView];
      NSView *sub = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 0, 0)]);
      NSLayoutConstraint *left;
      NSLayoutConstraint *width;
      NSLayoutConstraint *other;
      NSLayoutConstraint *kept;

      [sub setTranslatesAutoresizingMaskIntoConstraints: NO];
      [content addSubview: sub];

      left = [[sub leftAnchor] constraintEqualToAnchor: [content leftAnchor]
                                              constant: 20.0];
      width = [[sub widthAnchor] constraintEqualToConstant: 80.0];
      [left setActive: YES];
      [width setActive: YES];
      [[[sub bottomAnchor] constraintEqualToAnchor: [content bottomAnchor]
                                          constant: 10.0] setActive: YES];
      [[[sub heightAnchor] constraintEqualToConstant: 30.0] setActive: YES];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].size.width - 80.0) < 0.01, "the first layout uses 80");

      [width setConstant: 120.0];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].size.width - 120.0) < 0.01,
        "a new constant on an active constraint drives the next layout");

      [width setConstant: 60.0];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].size.width - 60.0) < 0.01,
        "and a second one does too");

      [left setConstant: 35.0];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].origin.x - 35.0) < 0.01,
        "a constant between two views works as well");

      [width setActive: NO];
      PASS([width isActive] == NO, "a constraint with a new constant can go");
      [width setConstant: 200.0];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].size.width - 200.0) > 0.01,
        "a constant on an inactive constraint does nothing");

      [width setActive: YES];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].size.width - 200.0) < 0.01,
        "activating it again uses its constant");
      [width setActive: NO];
      [width setActive: YES];
      [width setConstant: 90.0];
      [w layoutIfNeeded];
      PASS(fabs([sub frame].size.width - 90.0) < 0.01,
        "and it's watched after being activated again");

      /* A constraint that outlives the layout engine of its window. */
      {
        CREATE_AUTORELEASE_POOL(pool);
        NSWindow *gone = [[NSWindow alloc]
          initWithContentRect: NSMakeRect(0, 0, 100, 100)
                    styleMask: NSWindowStyleMaskBorderless
                      backing: NSBackingStoreBuffered
                        defer: NO];
        NSView *inner = AUTORELEASE([[NSView alloc]
          initWithFrame: NSMakeRect(0, 0, 0, 0)]);

        [gone setReleasedWhenClosed: NO];
        [inner setTranslatesAutoresizingMaskIntoConstraints: NO];
        [[gone contentView] addSubview: inner];
        other = [[inner widthAnchor] constraintEqualToConstant: 10.0];
        kept = RETAIN(other);
        [other setActive: YES];
        [gone layoutIfNeeded];
        [gone close];
        RELEASE(gone);
        DESTROY(pool);
      }
      [kept setConstant: 11.0];
      PASS([kept constant] == 11.0, "a constraint outlives its window");
      RELEASE(kept);
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSLayoutConstraint constant relayout")
  return 0;
}
