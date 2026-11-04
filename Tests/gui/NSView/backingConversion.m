/* NSView converts to and from backing store pixels using its window's scale. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>

int
main(int argc, char **argv)
{
  START_SET("NSView backing conversion")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSView *v = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 50, 50)]);
      NSRect r = NSMakeRect(1, 2, 3, 4);
      NSWindow *w;
      CGFloat scale;

      PASS(NSEqualRects([v convertRectToBacking: r], r),
        "with no window a rect is unchanged");
      PASS(NSEqualPoints([v convertPointFromBacking: r.origin], r.origin),
        "with no window a point is unchanged");

      w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 200, 100)
                  styleMask: NSTitledWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      [[w contentView] addSubview: v];
      scale = [w userSpaceScaleFactor];
      PASS(NSEqualRects([v convertRectToBacking: r],
        NSMakeRect(1 * scale, 2 * scale, 3 * scale, 4 * scale)),
        "a rect is scaled by the window's scale");
      PASS(NSEqualSizes([v convertSizeToBacking: r.size],
        NSMakeSize(3 * scale, 4 * scale)), "a size is scaled");
      PASS(NSEqualRects([v convertRectFromBacking: [v convertRectToBacking: r]], r),
        "converting a rect back gives the same rect");
      PASS(NSEqualSizes([v convertSizeFromBacking: [v convertSizeToBacking: r.size]],
        r.size), "converting a size back gives the same size");
      PASS(NSEqualPoints([v convertPointFromBacking: [v convertPointToBacking: r.origin]],
        r.origin), "converting a point back gives the same point");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSView backing conversion")

  return 0;
}
