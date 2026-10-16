/* -colorizeByMappingGray:toColor:blackMapping:whiteMapping: maps each
   pixel's gray level to a color: black to the black mapping, the mid
   point to the mid point color and white to the white mapping, between
   them in proportion, keeping the pixel's alpha.  It used to do nothing.
   The bitmap is a plain model object and needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>

static BOOL
isColor(NSColor *c, CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
  c = [c colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  return fabs([c redComponent] - r) < 0.02
    && fabs([c greenComponent] - g) < 0.02
    && fabs([c blueComponent] - b) < 0.02
    && fabs([c alphaComponent] - a) < 0.02;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSBitmapImageRep *rep;

  START_SET("NSBitmapImageRep colorize")

  rep = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
                  pixelsWide: 5
                  pixelsHigh: 1
               bitsPerSample: 8
             samplesPerPixel: 4
                    hasAlpha: YES
                    isPlanar: NO
              colorSpaceName: NSCalibratedRGBColorSpace
                 bytesPerRow: 0
                bitsPerPixel: 0]);
  [rep setColor: [NSColor colorWithCalibratedWhite: 0.0 alpha: 1.0] atX: 0 y: 0];
  [rep setColor: [NSColor colorWithCalibratedWhite: 0.25 alpha: 1.0] atX: 1 y: 0];
  [rep setColor: [NSColor colorWithCalibratedWhite: 0.5 alpha: 1.0] atX: 2 y: 0];
  [rep setColor: [NSColor colorWithCalibratedWhite: 1.0 alpha: 1.0] atX: 3 y: 0];
  [rep setColor: [NSColor colorWithCalibratedWhite: 1.0 alpha: 0.5] atX: 4 y: 0];

  [rep colorizeByMappingGray: 0.5
                     toColor: [NSColor colorWithCalibratedRed: 0 green: 1
                                                         blue: 0 alpha: 1]
                blackMapping: [NSColor colorWithCalibratedRed: 1 green: 0
                                                         blue: 0 alpha: 1]
                whiteMapping: [NSColor colorWithCalibratedRed: 0 green: 0
                                                         blue: 1 alpha: 1]];
  PASS(isColor([rep colorAtX: 0 y: 0], 1, 0, 0, 1),
    "black maps to the black mapping");
  PASS(isColor([rep colorAtX: 1 y: 0], 0.5, 0.5, 0, 1),
    "a gray below the mid point maps between the black mapping and the mid point color");
  PASS(isColor([rep colorAtX: 2 y: 0], 0, 1, 0, 1),
    "the mid point maps to the mid point color");
  PASS(isColor([rep colorAtX: 3 y: 0], 0, 0, 1, 1),
    "white maps to the white mapping");
  PASS([[rep colorAtX: 4 y: 0] alphaComponent] < 0.6
    && [[rep colorAtX: 4 y: 0] alphaComponent] > 0.4,
    "a pixel keeps its alpha");

  END_SET("NSBitmapImageRep colorize")

  DESTROY(arp);
  return 0;
}
