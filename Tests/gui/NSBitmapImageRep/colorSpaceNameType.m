/* NSColorSpaceName is a typed string enumeration, as in Cocoa, so Swift
   can import it as a structure with the color space names as members
   (.deviceRGB, ...).  The names were plain NSString globals.  They keep
   their values, and a bitmap made with a color space name answers it.
   Needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSGraphics.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSColorSpaceName	name = NSDeviceRGBColorSpace;
  NSBitmapImageRep	*rep;

  START_SET("NSColorSpaceName")

  PASS([NSCalibratedWhiteColorSpace isEqual: @"NSCalibratedWhiteColorSpace"]
    && [NSCalibratedBlackColorSpace isEqual: @"NSCalibratedBlackColorSpace"]
    && [NSCalibratedRGBColorSpace isEqual: @"NSCalibratedRGBColorSpace"]
    && [NSDeviceWhiteColorSpace isEqual: @"NSDeviceWhiteColorSpace"]
    && [NSDeviceBlackColorSpace isEqual: @"NSDeviceBlackColorSpace"]
    && [NSDeviceRGBColorSpace isEqual: @"NSDeviceRGBColorSpace"]
    && [NSDeviceCMYKColorSpace isEqual: @"NSDeviceCMYKColorSpace"]
    && [NSNamedColorSpace isEqual: @"NSNamedColorSpace"]
    && [NSPatternColorSpace isEqual: @"NSPatternColorSpace"]
    && [NSCustomColorSpace isEqual: @"NSCustomColorSpace"],
    "the color space names keep their values");

  rep = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
		  pixelsWide: 2
		  pixelsHigh: 2
	       bitsPerSample: 8
	     samplesPerPixel: 4
		    hasAlpha: YES
		    isPlanar: NO
	      colorSpaceName: name
		 bytesPerRow: 0
		bitsPerPixel: 0]);
  PASS([[rep colorSpaceName] isEqual: NSDeviceRGBColorSpace],
    "a bitmap answers the color space name it was made with");

  END_SET("NSColorSpaceName")

  [arp release];
  return 0;
}
