/* The NSEvent accessors that Cocoa declares as properties are declared
   properties, so Swift imports event.type and event.modifierFlags as
   properties.  They were methods only.  The methods remain their getters,
   so message syntax and property syntax answer the same values, and the
   properties add no instance variables. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <objc/runtime.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSEvent		*event;
  Ivar			*ivars;
  unsigned int		count;
  unsigned int		i;
  BOOL			synthesized = NO;

  START_SET("NSEvent accessor properties")

  PASS(class_getProperty([NSEvent class], "type") != NULL
    && class_getProperty([NSEvent class], "modifierFlags") != NULL
    && class_getProperty([NSEvent class], "locationInWindow") != NULL
    && class_getProperty([NSEvent class], "ARepeat") != NULL,
    "type, modifierFlags, locationInWindow and ARepeat are properties");
  PASS(class_getProperty(object_getClass([NSEvent class]), "modifierFlags")
    != NULL
    && class_getProperty(object_getClass([NSEvent class]), "mouseLocation")
    != NULL,
    "modifierFlags and mouseLocation are also class properties");

  ivars = class_copyIvarList([NSEvent class], &count);
  for (i = 0; i < count; i++)
    {
      if (ivar_getName(ivars[i])[0] == '_')
	{
	  synthesized = YES;
	}
    }
  free(ivars);
  PASS(synthesized == NO, "no instance variable is synthesized");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  event = [NSEvent keyEventWithType: NSKeyDown
			   location: NSMakePoint(3, 4)
		      modifierFlags: NSEventModifierFlagCommand
			  timestamp: 7
		       windowNumber: 0
			    context: nil
			 characters: @"a"
		charactersIgnoringModifiers: @"A"
			  isARepeat: YES
			    keyCode: 38];
  PASS(event.type == NSEventTypeKeyDown
    && event.type == [event type],
    "event.type answers -type");
  PASS((event.modifierFlags & NSEventModifierFlagCommand) != 0
    && event.modifierFlags == [event modifierFlags],
    "event.modifierFlags answers -modifierFlags");
  PASS(event.timestamp == 7 && event.keyCode == 38 && event.ARepeat
    && NSEqualPoints(event.locationInWindow, NSMakePoint(3, 4))
    && [event.characters isEqualToString: @"a"]
    && [event.charactersIgnoringModifiers isEqualToString: @"A"],
    "the other key event properties answer their methods");
  PASS(NSEvent.modifierFlags == [NSEvent modifierFlags],
    "NSEvent.modifierFlags answers +modifierFlags");

  END_SET("NSEvent accessor properties")

  [arp release];
  return 0;
}
