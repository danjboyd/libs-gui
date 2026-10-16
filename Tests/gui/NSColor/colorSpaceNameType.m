/* -[NSColor colorSpaceName], -colorUsingColorSpaceName: (and its device:
   variant), NSBestDepth(), NSColorSpaceFromDepth() and
   NSNumberOfColorComponents() use NSColorSpaceName, as in Cocoa, so Swift
   passes and compares the names as .calibratedRGB, .deviceRGB...  They
   used NSString, which NSColorSpaceName is, so they behave as before. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSColor		*color;
  NSColorSpaceName	name;

  START_SET("NSColorSpaceName parameters and results")

  color = [NSColor colorWithCalibratedRed: 1.0 green: 0.5 blue: 0.0 alpha: 1.0];
  name = [color colorSpaceName];
  PASS_EQUAL(name, NSCalibratedRGBColorSpace,
    "-colorSpaceName answers an NSColorSpaceName");

  color = [color colorUsingColorSpaceName: NSDeviceRGBColorSpace];
  PASS_EQUAL([color colorSpaceName], NSDeviceRGBColorSpace,
    "-colorUsingColorSpaceName: converts to the named color space");
  color = [color colorUsingColorSpaceName: NSCalibratedWhiteColorSpace
				   device: nil];
  PASS_EQUAL([color colorSpaceName], NSCalibratedWhiteColorSpace,
    "-colorUsingColorSpaceName:device: converts to the named color space");

  PASS(NSNumberOfColorComponents(NSDeviceRGBColorSpace) == 3
    && NSNumberOfColorComponents(NSDeviceCMYKColorSpace) == 4
    && NSNumberOfColorComponents(NSCalibratedWhiteColorSpace) == 1,
    "NSNumberOfColorComponents() takes an NSColorSpaceName");

  name = NSColorSpaceFromDepth(0);
  PASS_EQUAL(name, NSCalibratedBlackColorSpace,
    "NSColorSpaceFromDepth() answers an NSColorSpaceName");

  END_SET("NSColorSpaceName parameters and results")

  [arp release];
  return 0;
}
