/* NSTrackingAreaOptions is an NS_OPTIONS type, as in Cocoa, so Swift can
   import it as an option set (NSTrackingArea.Options).  It was an
   NSUInteger typedef beside an anonymous enumeration.  The options keep
   their values, the type keeps its size and type encoding, and combined
   options still reach the tracking area.  Needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSTrackingArea.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSTrackingAreaOptions	options;
  NSTrackingArea	*area;

  START_SET("NSTrackingAreaOptions")

  PASS(sizeof(NSTrackingAreaOptions) == sizeof(NSUInteger)
    && strcmp(@encode(NSTrackingAreaOptions), @encode(NSUInteger)) == 0,
    "NSTrackingAreaOptions has the size and encoding of NSUInteger");
  PASS(NSTrackingMouseEnteredAndExited == 0x01
    && NSTrackingMouseMoved == 0x02
    && NSTrackingCursorUpdate == 0x04
    && NSTrackingActiveWhenFirstResponder == 0x10
    && NSTrackingActiveInKeyWindow == 0x20
    && NSTrackingActiveInActiveApp == 0x40
    && NSTrackingActiveAlways == 0x80
    && NSTrackingAssumeInside == 0x100
    && NSTrackingInVisibleRect == 0x200
    && NSTrackingEnabledDuringMouseDrag == 0x400,
    "the tracking area options have Cocoa's values");

  options = NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow;
  area = AUTORELEASE([[NSTrackingArea alloc]
    initWithRect: NSMakeRect(0, 0, 10, 10)
	 options: options
	   owner: nil
	userInfo: nil]);
  PASS([area options] == (NSTrackingMouseEnteredAndExited
    | NSTrackingActiveInKeyWindow),
    "a tracking area keeps combined options");

  END_SET("NSTrackingAreaOptions")

  [arp release];
  return 0;
}
