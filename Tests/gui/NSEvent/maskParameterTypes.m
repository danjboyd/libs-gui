/* -sendActionOn: takes an NSEventMask, -keyEquivalentModifierMask and the
   modifierFlags: parameters of the NSEvent factories are
   NSEventModifierFlags, as in Cocoa, so Swift passes the option sets
   NSEvent.EventTypeMask and NSEvent.ModifierFlags to them.  They were
   NSInteger and NSUInteger.  The methods are declared and implemented
   with the new types, and masks and flags still round-trip. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSMethodSignature.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSButtonCell.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSControl.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSMenuItem.h>

static BOOL
argumentIs(Class c, SEL s, NSUInteger index, const char *type)
{
  NSMethodSignature	*sig = [c instanceMethodSignatureForSelector: s];

  return sig != nil && strcmp([sig getArgumentTypeAtIndex: index], type) == 0;
}

static BOOL
returnIs(Class c, SEL s, const char *type)
{
  NSMethodSignature	*sig = [c instanceMethodSignatureForSelector: s];

  return sig != nil && strcmp([sig methodReturnType], type) == 0;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSEventModifierFlags	flags = NSEventModifierFlagShift | NSEventModifierFlagCommand;
  NSCell		*cell;
  NSMenuItem		*item;
  NSButtonCell		*buttonCell;
  NSEvent		*event;

  START_SET("NSEventMask and NSEventModifierFlags parameters")

  PASS(argumentIs([NSCell class], @selector(sendActionOn:), 2,
    @encode(NSEventMask))
    && argumentIs([NSControl class], @selector(sendActionOn:), 2,
    @encode(NSEventMask)),
    "-sendActionOn: takes an NSEventMask");
  PASS(returnIs([NSMenuItem class], @selector(keyEquivalentModifierMask),
    @encode(NSEventModifierFlags))
    && argumentIs([NSMenuItem class], @selector(setKeyEquivalentModifierMask:),
    2, @encode(NSEventModifierFlags))
    && returnIs([NSButtonCell class], @selector(keyEquivalentModifierMask),
    @encode(NSEventModifierFlags))
    && returnIs([NSButton class], @selector(keyEquivalentModifierMask),
    @encode(NSEventModifierFlags)),
    "-keyEquivalentModifierMask is NSEventModifierFlags");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  cell = AUTORELEASE([[NSCell alloc] initTextCell: @""]);
  [cell sendActionOn: NSLeftMouseDownMask | NSPeriodicMask];
  PASS([cell sendActionOn: NSLeftMouseUpMask]
    == (NSInteger)(NSLeftMouseDownMask | NSPeriodicMask),
    "-sendActionOn: answers the previous mask");

  item = AUTORELEASE([[NSMenuItem alloc] initWithTitle: @"Item"
						 action: NULL
					  keyEquivalent: @"s"]);
  [item setKeyEquivalentModifierMask: flags];
  PASS([item keyEquivalentModifierMask] == flags,
    "a menu item keeps its key equivalent modifier flags");

  buttonCell = AUTORELEASE([[NSButtonCell alloc] initTextCell: @"OK"]);
  [buttonCell setKeyEquivalentModifierMask: NSEventModifierFlagOption];
  PASS([buttonCell keyEquivalentModifierMask] == NSEventModifierFlagOption,
    "a button cell keeps its key equivalent modifier flags");

  event = [NSEvent mouseEventWithType: NSLeftMouseDown
			     location: NSMakePoint(0, 0)
			modifierFlags: flags
			    timestamp: 0
			 windowNumber: 0
			      context: nil
			  eventNumber: 0
			   clickCount: 1
			     pressure: 1.0];
  PASS(([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask)
    == flags, "an event keeps the modifier flags it was made with");

  END_SET("NSEventMask and NSEventModifierFlags parameters")

  [arp release];
  return 0;
}
