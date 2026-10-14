/* NSReadPixel answers the colour of the pixel at a point of the focused
 * view.  It used to log that it was not implemented and answer nil.  Only
 * the bottom left quarter is filled, so a point inside and a point outside
 * it check that the point maps to the right pixel.  The pixels are read
 * back, so the set skips when the backend cannot draw offscreen.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"
#import "../GSDrawTest.h"

#import <AppKit/AppKit.h>

static BOOL
isRed(NSColor *c)
{
  c = [c colorUsingColorSpaceName: NSDeviceRGBColorSpace];
  return c != nil && [c redComponent] > 0.99
    && [c greenComponent] < 0.01 && [c blueComponent] < 0.01;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSImage *img;
  NSColor *inside;
  NSColor *outside;

  START_SET("NSReadPixel")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  if (NO == GSCanDrawOffscreen())
    {
      SKIP("the installed backend does not draw offscreen")
    }

  img = GSDrawBeginWhite(20, 20);
  [[NSColor colorWithDeviceRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0] set];
  NSRectFill(NSMakeRect(0, 0, 10, 10));
  inside = RETAIN(NSReadPixel(NSMakePoint(5, 5)));
  outside = RETAIN(NSReadPixel(NSMakePoint(15.5, 15.5)));
  GSDrawEnd(img, 20, 20);

  PASS(inside != nil && outside != nil, "NSReadPixel answers colours");
  PASS(isRed(inside), "a point in the filled quarter reads its colour");
  PASS(outside != nil && !isRed(outside),
    "a point outside the filled quarter does not");

  RELEASE(inside);
  RELEASE(outside);

  END_SET("NSReadPixel")

  [pool release];
  return 0;
}
