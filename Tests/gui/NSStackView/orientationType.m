/* NSUserInterfaceLayoutOrientation is an NS_ENUM type, as in Cocoa, so
   Swift can import it as an enumeration (.horizontal, .vertical).  It was
   an NSInteger typedef beside an anonymous enumeration.  The constants
   keep their values and the type keeps its size and type encoding.
   Needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSUserInterfaceLayout.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool			*arp = [NSAutoreleasePool new];
  NSUserInterfaceLayoutOrientation	o = NSUserInterfaceLayoutOrientationVertical;

  START_SET("NSUserInterfaceLayoutOrientation")

  PASS(sizeof(NSUserInterfaceLayoutOrientation) == sizeof(NSInteger)
    && strcmp(@encode(NSUserInterfaceLayoutOrientation),
      @encode(NSInteger)) == 0,
    "NSUserInterfaceLayoutOrientation has the size and encoding of NSInteger");
  PASS(NSUserInterfaceLayoutOrientationHorizontal == 0
    && NSUserInterfaceLayoutOrientationVertical == 1,
    "the orientations have Cocoa's values");
  PASS(o == 1, "an orientation holds its constant");

  END_SET("NSUserInterfaceLayoutOrientation")

  [arp release];
  return 0;
}
