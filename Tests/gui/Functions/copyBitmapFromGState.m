/* NSCopyBitmapFromGState copies a rectangle of a graphics state, in its
   coordinates, into a rectangle of the focused view, scaled to it.  It
   used to log that it was not implemented.  The window's pixels are read
   back, so the set skips without the backend. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

static BOOL
colorAt(NSBitmapImageRep *rep, NSInteger x, NSInteger y,
  CGFloat r, CGFloat g, CGFloat b)
{
  NSColor *c = [[rep colorAtX: x y: [rep pixelsHigh] - 1 - y]
    colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

  return fabs([c redComponent] - r) < 0.05
    && fabs([c greenComponent] - g) < 0.05
    && fabs([c blueComponent] - b) < 0.05;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSCopyBitmapFromGState")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(40, 40, 240, 200)
                  styleMask: NSBorderlessWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSView *canvas = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(20, 20, 100, 100)]);
      NSRect red = NSMakeRect(10, 10, 20, 20);
      NSBitmapImageRep *same;
      NSBitmapImageRep *scaled;

      [[w contentView] addSubview: canvas];
      [w orderFront: nil];

      [canvas lockFocus];
      [[NSColor whiteColor] set];
      NSRectFill([canvas bounds]);
      [[NSColor redColor] set];
      NSRectFill(red);
      NSCopyBitmapFromGState((int)[w gState], [canvas convertRect: red toView: nil],
        NSMakeRect(60, 10, 20, 20));
      same = AUTORELEASE([[NSBitmapImageRep alloc]
        initWithFocusedViewRect: [canvas bounds]]);
      [canvas unlockFocus];
      PASS(colorAt(same, 70, 20, 1, 0, 0) && colorAt(same, 45, 20, 1, 1, 1),
        "a rectangle is copied to a rectangle of the same size");

      [canvas lockFocus];
      [[NSColor whiteColor] set];
      NSRectFill([canvas bounds]);
      [[NSColor redColor] set];
      NSRectFill(red);
      NSCopyBitmapFromGState((int)[w gState], [canvas convertRect: red toView: nil],
        NSMakeRect(40, 40, 40, 40));
      scaled = AUTORELEASE([[NSBitmapImageRep alloc]
        initWithFocusedViewRect: [canvas bounds]]);
      [canvas unlockFocus];
      PASS(colorAt(scaled, 45, 45, 1, 0, 0) && colorAt(scaled, 75, 75, 1, 0, 0)
        && colorAt(scaled, 85, 85, 1, 1, 1) && colorAt(scaled, 35, 35, 1, 1, 1),
        "a rectangle is scaled to a larger rectangle");
      [w orderOut: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSCopyBitmapFromGState")

  DESTROY(arp);
  return 0;
}
