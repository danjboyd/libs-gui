/* A stack view made in code keeps its views by gravity, and they are its own
 * subviews.
 */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSException.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSStackView.h>
#include <AppKit/NSView.h>

static NSView *
view(void)
{
  return AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)]);
}

int main()
{
  CREATE_AUTORELEASE_POOL(arp);

  START_SET("NSStackView gravity")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqual: NSInternalInconsistencyException])
        {
          SKIP("It looks like GNUstep backend is not yet installed")
        }
    }
  NS_ENDHANDLER

  NSStackView *sv = AUTORELEASE([[NSStackView alloc]
    initWithFrame: NSMakeRect(0, 0, 240, 40)]);
  NSView *a = view();
  NSView *b = view();
  NSView *c = view();
  NSView *d = view();
  NSView *e = view();

  PASS([[sv viewsInGravity: NSStackViewGravityLeading] count] == 0,
       "a gravity starts empty");

  [sv addView: a inGravity: NSStackViewGravityLeading];
  [sv addView: b inGravity: NSStackViewGravityLeading];
  PASS([a superview] == sv && [b superview] == sv,
       "a view added in a gravity is a subview of the stack view");
  PASS_EQUAL([sv viewsInGravity: NSStackViewGravityLeading],
             ([NSArray arrayWithObjects: a, b, nil]),
             "the gravity lists its views in order");
  PASS([[sv viewsInGravity: NSStackViewGravityCenter] count] == 0,
       "the other gravities don't list them");

  [sv insertView: c atIndex: 1 inGravity: NSStackViewGravityLeading];
  PASS_EQUAL([sv viewsInGravity: NSStackViewGravityLeading],
             ([NSArray arrayWithObjects: a, c, b, nil]),
             "inserting puts a view at its index");
  PASS([c superview] == sv, "an inserted view is a subview");

  [sv addView: c inGravity: NSStackViewGravityCenter];
  PASS_EQUAL([sv viewsInGravity: NSStackViewGravityCenter],
             ([NSArray arrayWithObject: c]),
             "adding a view moves it to the new gravity");
  PASS_EQUAL([sv viewsInGravity: NSStackViewGravityLeading],
             ([NSArray arrayWithObjects: a, b, nil]),
             "and takes it out of the old one");

  [sv setViews: [NSArray arrayWithObject: d]
     inGravity: NSStackViewGravityTrailing];
  [sv setViews: [NSArray arrayWithObject: e]
     inGravity: NSStackViewGravityTrailing];
  PASS([e superview] == sv && [d superview] == nil,
       "setting views replaces the gravity's subviews");
  PASS_EQUAL([sv viewsInGravity: NSStackViewGravityTrailing],
             ([NSArray arrayWithObject: e]),
             "the gravity lists the new views");

  [sv removeView: a];
  PASS([a superview] == nil, "removing a view takes it out of the stack view");
  PASS_EQUAL([sv viewsInGravity: NSStackViewGravityLeading],
             ([NSArray arrayWithObject: b]),
             "and out of its gravity");

  [b removeFromSuperview];
  PASS([[sv viewsInGravity: NSStackViewGravityLeading] count] == 0,
       "a view removed by itself leaves its gravity too");

  PASS_EXCEPTION([sv addView: a inGravity: 0],
                 NSInternalInconsistencyException,
                 "an unknown gravity raises");
  PASS_EXCEPTION([sv viewsInGravity: 4],
                 NSInternalInconsistencyException,
                 "for listing as well");

  END_SET("NSStackView gravity")
  DESTROY(arp);
  return 0;
}
