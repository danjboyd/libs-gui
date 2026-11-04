/* -initWithSize:flipped:drawingHandler: draws by calling the handler, in the
   image's own coordinates, and each time the image is drawn. */
#import "Testing.h"

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsContext.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSView.h>

/* Renders the image at the origin into a bitmap. */
static NSBitmapImageRep *
render(NSImage *image, NSSize size)
{
  NSBitmapImageRep *rep;

  rep = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
                  pixelsWide: size.width
                  pixelsHigh: size.height
               bitsPerSample: 8
             samplesPerPixel: 4
                    hasAlpha: YES
                    isPlanar: NO
              colorSpaceName: NSCalibratedRGBColorSpace
                 bytesPerRow: 0
                bitsPerPixel: 0]);
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:
    [NSGraphicsContext graphicsContextWithBitmapImageRep: rep]];
  [image drawAtPoint: NSZeroPoint
            fromRect: NSZeroRect
           operation: NSCompositeSourceOver
            fraction: 1.0];
  [[NSGraphicsContext currentContext] flushGraphics];
  [NSGraphicsContext restoreGraphicsState];
  return rep;
}

/* Red in the bottom half of the image's own coordinates, as its handler sees
   them. */
static BOOL (^bottomRed)(NSRect) = ^BOOL(NSRect r) {
  [[NSColor redColor] set];
  NSRectFill(NSMakeRect(0, 0, r.size.width, r.size.height / 2));
  return YES;
};

int
main(int argc, char **argv)
{
  START_SET("NSImage drawing handler")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSSize size = NSMakeSize(20, 20);
      __block int calls = 0;
      __block NSRect seen = NSZeroRect;
      NSImage *plain;
      NSImage *flipped;
      NSBitmapImageRep *rep;
      CGFloat low;
      CGFloat high;

      plain = AUTORELEASE([[NSImage alloc] initWithSize: size
                                                flipped: NO
                                         drawingHandler: ^BOOL(NSRect r) {
        calls++;
        seen = r;
        return bottomRed(r);
      }]);
      PASS(NSEqualSizes([plain size], size), "the image has the size given");
      PASS(calls == 0, "the handler isn't called until the image is drawn");

      rep = render(plain, size);
      PASS(calls == 1, "drawing calls the handler");
      PASS(NSEqualRects(seen, NSMakeRect(0, 0, 20, 20)),
        "the handler gets the image's rect");
      low = [[[rep colorAtX: 10 y: 15] colorUsingColorSpaceName:
        NSCalibratedRGBColorSpace] redComponent];
      high = [[[rep colorAtX: 10 y: 5] colorUsingColorSpaceName:
        NSCalibratedRGBColorSpace] alphaComponent];
      PASS(low == 1.0 && high == 0.0, "what the handler draws reaches the image");

      flipped = AUTORELEASE([[NSImage alloc] initWithSize: size
                                                  flipped: YES
                                           drawingHandler: bottomRed]);
      rep = render(flipped, size);
      low = [[[rep colorAtX: 10 y: 15] colorUsingColorSpaceName:
        NSCalibratedRGBColorSpace] alphaComponent];
      high = [[[rep colorAtX: 10 y: 5] colorUsingColorSpaceName:
        NSCalibratedRGBColorSpace] redComponent];
      PASS(low == 0.0 && high == 1.0, "a flipped image has its origin at the top");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSImage drawing handler")

  return 0;
}
