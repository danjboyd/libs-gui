/* The NSAccessibilitySwitch actions of NSSwitch: a press toggles the switch
   as a click does, increment and decrement turn it on and off, sending the
   action when the state changes, and the value is the state as a string.
   They used to do nothing and answer NO, and the value was nil.  The switch
   uses the theme and font backend, so the set is skipped when the backend
   is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSSwitch.h>

@interface AXSwitchTarget : NSObject
{
@public
  int count;
}
- (void) toggled: (id)sender;
@end

@implementation AXSwitchTarget
- (void) toggled: (id)sender
{
  count++;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSwitch *sw;
  AXSwitchTarget *t;

  START_SET("NSSwitch accessibility")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  t = AUTORELEASE([AXSwitchTarget new]);
  sw = AUTORELEASE([[NSSwitch alloc] initWithFrame: NSMakeRect(0, 0, 60, 24)]);
  [sw setTarget: t];
  [sw setAction: @selector(toggled:)];
  [sw setState: NSControlStateValueOff];

  PASS([sw accessibilityPerformPress] == YES
    && [sw state] == NSControlStateValueOn && t->count == 1,
    "a press toggles the switch and sends the action");
  PASS_EQUAL([sw accessibilityValue], [sw stringValue],
    "the accessibility value is the string value");

  PASS([sw accessibilityPerformDecrement] == YES
    && [sw state] == NSControlStateValueOff && t->count == 2,
    "a decrement turns the switch off and sends the action");
  PASS([sw accessibilityPerformDecrement] == YES && t->count == 2,
    "a decrement of a switch that is off sends no action");
  PASS([sw accessibilityPerformIncrement] == YES
    && [sw state] == NSControlStateValueOn && t->count == 3,
    "an increment turns the switch on and sends the action");

  [sw setEnabled: NO];
  PASS([sw accessibilityPerformPress] == NO
    && [sw state] == NSControlStateValueOn,
    "a disabled switch ignores a press");

  END_SET("NSSwitch accessibility")

  [pool release];
  return 0;
}
