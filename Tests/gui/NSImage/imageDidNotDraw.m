/* An image that has no representation to draw asks its delegate's
 * -imageDidNotDraw:inRect: for an image to draw in its place, and draws it
 * in the same rectangle.  The delegate used to be ignored.  Drawing needs a
 * backend that draws offscreen, so the set skips without one.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"
#import "../GSDrawTest.h"

#import <AppKit/AppKit.h>

@interface NotDrawnDelegate : NSObject
{
@public
  int calls;
  id sender;
  NSRect rect;
  NSImage *replacement;
}
@end

@implementation NotDrawnDelegate
- (NSImage *) imageDidNotDraw: (id)s inRect: (NSRect)r
{
  calls++;
  sender = s;
  rect = r;
  return replacement;
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSImage imageDidNotDraw")

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

  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSBitmapImageRep *rep, *out;
  NSImage *empty, *red, *canvas;
  NotDrawnDelegate *delegate;
  unsigned char *d;
  int i;

  /* A solid red 2x2 image to draw in place of the empty one. */
  rep = [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL pixelsWide: 2 pixelsHigh: 2
                bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: YES isPlanar: NO
               colorSpaceName: NSDeviceRGBColorSpace bytesPerRow: 8 bitsPerPixel: 32];
  d = [rep bitmapData];
  for (i = 0; i < 4; i++)
    { d[i * 4] = 255; d[i * 4 + 1] = 0; d[i * 4 + 2] = 0; d[i * 4 + 3] = 255; }
  red = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(2, 2)]);
  [red addRepresentation: rep];
  [rep release];

  empty = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(4, 4)]);
  delegate = AUTORELEASE([NotDrawnDelegate new]);
  delegate->replacement = red;
  [empty setDelegate: delegate];

  canvas = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(20, 20)]);
  [canvas lockFocus];
  [[NSColor blackColor] set];
  NSRectFill(NSMakeRect(0, 0, 20, 20));
  [empty drawInRect: NSMakeRect(5, 5, 10, 10)];
  [[NSGraphicsContext currentContext] flushGraphics];
  out = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithFocusedViewRect: NSMakeRect(0, 0, 20, 20)]);
  [canvas unlockFocus];
  [empty setDelegate: nil];

  PASS(delegate->calls == 1 && delegate->sender == empty,
       "the delegate is asked once, with the image as the sender");
  PASS(NSEqualRects(delegate->rect, NSMakeRect(5, 5, 10, 10)),
       "the delegate is given the rectangle being drawn");
  PASS(GSPixelIs(out, 10, 10, 255, 0, 0) && GSPixelIs(out, 2, 2, 0, 0, 0),
       "the delegate's image is drawn in the rectangle");

  [pool release];
  END_SET("NSImage imageDidNotDraw")

  return 0;
}
