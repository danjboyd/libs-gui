/* A bitmap with alpha made from data is opaque when every alpha sample is
   fully opaque.  The scan used to read the last byte of each pixel, so an
   opaque NSAlphaFirstBitmapFormat bitmap was taken for a transparent one,
   and it ignored the padding at the end of a row. */
#include "Testing.h"

#include <string.h>

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSBitmapImageRep.h>
#include <AppKit/NSGraphics.h>

static NSBitmapImageRep *
rep(unsigned char *data, BOOL alphaFirst, NSInteger rowBytes, NSInteger bps,
    BOOL planar)
{
  unsigned char *planes[4];
  int i;

  for (i = 0; i < 4; i++)
    planes[i] = data + i * rowBytes * 2;
  return AUTORELEASE([[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: planes
                  pixelsWide: 3
                  pixelsHigh: 2
               bitsPerSample: bps
             samplesPerPixel: 4
                    hasAlpha: YES
                    isPlanar: planar
              colorSpaceName: NSDeviceRGBColorSpace
                bitmapFormat: alphaFirst ? NSAlphaFirstBitmapFormat : 0
                 bytesPerRow: rowBytes
                bitsPerPixel: planar ? bps : 4 * bps]);
}

/* Fills 3x2 meshed 8 bit pixels with opaque alpha and zero colours, with
   rows of 16 bytes whose last 4 are zero padding. */
static void
fill(unsigned char *data, BOOL alphaFirst)
{
  int y, x;

  memset(data, 0, 32);
  for (y = 0; y < 2; y++)
    for (x = 0; x < 3; x++)
      data[y * 16 + x * 4 + (alphaFirst ? 0 : 3)] = 255;
}

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  unsigned char data[96];

  START_SET("NSBitmapImageRep opaqueScan")

  fill(data, YES);
  PASS([rep(data, YES, 16, 8, NO) isOpaque],
       "an opaque alpha first bitmap is opaque");
  fill(data, NO);
  PASS([rep(data, NO, 16, 8, NO) isOpaque],
       "an opaque alpha last bitmap with padded rows is opaque");
  fill(data, YES);
  data[16 + 2 * 4] = 128;
  PASS(![rep(data, YES, 16, 8, NO) isOpaque],
       "an alpha first bitmap with a translucent pixel is not opaque");
  fill(data, NO);
  data[16 + 2 * 4 + 3] = 0;
  PASS(![rep(data, NO, 16, 8, NO) isOpaque],
       "an alpha last bitmap with a transparent pixel is not opaque");

  /* Planar: four planes of 3x2 samples, the alpha plane first or last. */
  memset(data, 0, sizeof(data));
  memset(data, 255, 6);
  PASS([rep(data, YES, 3, 8, YES) isOpaque],
       "an opaque planar alpha first bitmap is opaque");
  PASS(![rep(data, NO, 3, 8, YES) isOpaque],
       "a planar alpha last bitmap with a transparent alpha plane is not opaque");

  /* 16 bits per sample, alpha last, rows of 24 bytes. */
  memset(data, 0, sizeof(data));
  {
    int y, x;

    for (y = 0; y < 2; y++)
      for (x = 0; x < 3; x++)
        {
          data[y * 24 + x * 8 + 6] = 255;
          data[y * 24 + x * 8 + 7] = 255;
        }
  }
  PASS([rep(data, NO, 24, 16, NO) isOpaque],
       "an opaque 16 bit bitmap is opaque");
  data[24 + 6] = 0;
  PASS(![rep(data, NO, 24, 16, NO) isOpaque],
       "a 16 bit bitmap with a translucent pixel is not opaque");

  END_SET("NSBitmapImageRep opaqueScan")

  DESTROY(arp);
  return 0;
}
