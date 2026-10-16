/* NSEventMask is an NS_OPTIONS type, as in Cocoa, so Swift can import it
   as an option set (NSEvent.EventTypeMask), and the event matching methods
   of NSApplication and NSWindow take it.  It was an unsigned long long
   typedef beside an anonymous enumeration, and the methods took an
   NSUInteger, which has the same size and encoding on 64-bit targets.
   The masks keep their values and the type keeps its size and type
   encoding.  Needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSMethodSignature.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSEventMask		mask;
  NSMethodSignature	*sig;

  START_SET("NSEventMask")

  PASS(sizeof(NSEventMask) == sizeof(unsigned long long)
    && strcmp(@encode(NSEventMask), @encode(unsigned long long)) == 0,
    "NSEventMask has the size and encoding of unsigned long long");
  PASS(NSLeftMouseDownMask == 1 << NSLeftMouseDown
    && NSLeftMouseUpMask == 1 << NSLeftMouseUp
    && NSLeftMouseDraggedMask == 1 << NSLeftMouseDragged
    && NSKeyDownMask == 1 << NSKeyDown
    && NSAppKitDefinedMask == 1 << NSAppKitDefined
    && NSOtherMouseDraggedMask == 1 << NSOtherMouseDragged
    && NSAnyEventMask == 0xffffffffU,
    "the event masks have Cocoa's values");
  PASS(NSEventMaskFromType(NSKeyUp) == NSKeyUpMask,
    "NSEventMaskFromType answers the mask of a type");

  mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;
  PASS((mask & GSTrackingLoopMask) == mask,
    "event masks combine and mask");

  sig = [NSWindow instanceMethodSignatureForSelector:
    @selector(nextEventMatchingMask:untilDate:inMode:dequeue:)];
  PASS(sig != nil && strcmp([sig getArgumentTypeAtIndex: 2],
    @encode(NSEventMask)) == 0,
    "-[NSWindow nextEventMatchingMask:...] has the encoding of an NSEventMask mask");
  sig = [NSApplication instanceMethodSignatureForSelector:
    @selector(discardEventsMatchingMask:beforeEvent:)];
  PASS(sig != nil && strcmp([sig getArgumentTypeAtIndex: 2],
    @encode(NSEventMask)) == 0,
    "-[NSApplication discardEventsMatchingMask:...] has the encoding of an NSEventMask mask");

  END_SET("NSEventMask")

  [arp release];
  return 0;
}
