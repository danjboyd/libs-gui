/* NSEventModifierFlags is an NS_OPTIONS type, as in Cocoa, so Swift can
   import it as an option set (NSEvent.ModifierFlags).  It was an
   NSUInteger typedef beside an anonymous enumeration.  The flags keep
   their values, the type keeps its size and type encoding, and an event
   made with combined flags answers them. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSEventModifierFlags	flags;
  NSEvent		*event;

  START_SET("NSEventModifierFlags")

  PASS(sizeof(NSEventModifierFlags) == sizeof(NSUInteger)
    && strcmp(@encode(NSEventModifierFlags), @encode(NSUInteger)) == 0,
    "NSEventModifierFlags has the size and encoding of NSUInteger");
  PASS(NSEventModifierFlagCapsLock == 1 << 16
    && NSEventModifierFlagShift == 1 << 17
    && NSEventModifierFlagControl == 1 << 18
    && NSEventModifierFlagOption == 1 << 19
    && NSEventModifierFlagCommand == 1 << 20
    && NSEventModifierFlagNumericPad == 1 << 21
    && NSHelpKeyMask == 1 << 22
    && NSEventModifierFlagFunction == 1 << 23
    && NSEventModifierFlagDeviceIndependentFlagsMask == 0xffff0000U,
    "the modifier flags have Cocoa's values");
  PASS(NSAlphaShiftKeyMask == NSEventModifierFlagCapsLock
    && NSShiftKeyMask == NSEventModifierFlagShift
    && NSControlKeyMask == NSEventModifierFlagControl
    && NSAlternateKeyMask == NSEventModifierFlagOption
    && NSCommandKeyMask == NSEventModifierFlagCommand
    && NSNumericPadKeyMask == NSEventModifierFlagNumericPad
    && NSFunctionKeyMask == NSEventModifierFlagFunction
    && NSDeviceIndependentModifierFlagsMask
      == NSEventModifierFlagDeviceIndependentFlagsMask,
    "the older names have the same values");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  flags = NSEventModifierFlagShift | NSEventModifierFlagCommand;
  event = [NSEvent keyEventWithType: NSKeyDown
			   location: NSMakePoint(0, 0)
		      modifierFlags: flags
			  timestamp: 0
		       windowNumber: 0
			    context: nil
			 characters: @"a"
		charactersIgnoringModifiers: @"a"
			  isARepeat: NO
			    keyCode: 0];
  PASS(([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask)
    == flags, "an event answers combined modifier flags");

  END_SET("NSEventModifierFlags")

  [arp release];
  return 0;
}
