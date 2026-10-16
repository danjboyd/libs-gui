/* NSEventType is an NS_ENUM type, as in Cocoa, so Swift can import it as
   an enumeration (NSEvent.EventType).  It was an NSUInteger typedef beside
   an anonymous enumeration.  The event types keep their values, the type
   keeps its size and type encoding, and an event answers the type it was
   made with. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSEvent		*event;

  START_SET("NSEventType")

  PASS(sizeof(NSEventType) == sizeof(NSUInteger)
    && strcmp(@encode(NSEventType), @encode(NSUInteger)) == 0,
    "NSEventType has the size and encoding of NSUInteger");
  PASS(NSEventTypeLeftMouseDown == 1
    && NSEventTypeLeftMouseUp == 2
    && NSEventTypeMouseMoved == 5
    && NSEventTypeKeyDown == 10
    && NSEventTypeFlagsChanged == 12
    && NSEventTypeApplicationDefined == 15
    && NSEventTypePeriodic == 16
    && NSEventTypeCursorUpdate == 17
    && NSEventTypeScrollWheel == 22
    && NSEventTypeOtherMouseDragged == 27
    && NSEventTypeChangeMode == 38,
    "the event types have Cocoa's values");
  PASS(NSLeftMouseDown == NSEventTypeLeftMouseDown
    && NSRightMouseUp == NSEventTypeRightMouseUp
    && NSKeyUp == NSEventTypeKeyUp
    && NSAppKitDefined == NSEventTypeAppKitDefined
    && NSScrollWheel == NSEventTypeScrollWheel
    && NSTabletProximity == NSEventTypeTabletProximity
    && NSOtherMouseDown == NSEventTypeOtherMouseDown,
    "the older names have the same values");
  PASS(NSEventMaskFromType(NSEventTypeKeyDown) == NSKeyDownMask,
    "NSEventMaskFromType() takes an NSEventType");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  event = [NSEvent otherEventWithType: NSEventTypeApplicationDefined
			     location: NSMakePoint(0, 0)
			modifierFlags: 0
			    timestamp: 0
			 windowNumber: 0
			      context: nil
			      subtype: 0
				data1: 0
				data2: 0];
  PASS([event type] == NSEventTypeApplicationDefined,
    "an event answers the type it was made with");

  END_SET("NSEventType")

  [arp release];
  return 0;
}
