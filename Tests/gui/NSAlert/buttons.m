/* A click on a button from -buttons (here -performClick:) ends the alert
   with that button's return code, as a click on the button the panel shows
   does.  The alert runs modally, so a timer clicks the button and posts an
   event to wake the modal loop, which waits for one.  Running the alert
   needs a backend, so the set is skipped when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSRunLoop.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSAlert.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSPanel.h>

@interface Clicker : NSObject
@end

static void
wake(void)
{
  [NSApp postEvent: [NSEvent otherEventWithType: NSApplicationDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: 0
                                        context: nil
                                        subtype: 0
                                          data1: 0
                                          data2: 0]
           atStart: NO];
}

@implementation Clicker
- (void) click: (NSButton *)button
{
  [button performClick: nil];
  wake();
}
/* Ends a session the click failed to end, so the test cannot hang. */
- (void) giveUp: (id)ignored
{
  [NSApp stopModalWithCode: 0];
  wake();
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSAlert buttons")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSArray *modes = [NSArray arrayWithObject: NSModalPanelRunLoopMode];
      Clicker *clicker = AUTORELEASE([Clicker new]);
      NSAlert *a = AUTORELEASE([[NSAlert alloc] init]);
      NSInteger result;

      [a setMessageText: @"Save changes?"];
      [a addButtonWithTitle: @"Save"];
      [a addButtonWithTitle: @"Cancel"];
      [a addButtonWithTitle: @"Don't Save"];

      [clicker performSelector: @selector(click:)
                    withObject: [[a buttons] objectAtIndex: 1]
                    afterDelay: 0.1
                       inModes: modes];
      [clicker performSelector: @selector(giveUp:)
                    withObject: nil
                    afterDelay: 5.0
                       inModes: modes];
      result = [a runModal];
      [NSObject cancelPreviousPerformRequestsWithTarget: clicker];
      PASS(result == NSAlertSecondButtonReturn,
        "clicking the second of -buttons ends -runModal with its code");

      [clicker performSelector: @selector(click:)
                    withObject: [[a buttons] objectAtIndex: 2]
                    afterDelay: 0.1
                       inModes: modes];
      [clicker performSelector: @selector(giveUp:)
                    withObject: nil
                    afterDelay: 5.0
                       inModes: modes];
      result = [a runModal];
      [NSObject cancelPreviousPerformRequestsWithTarget: clicker];
      PASS(result == NSAlertThirdButtonReturn,
        "the alert can be run again and ended by another button");

      /* Outside a modal session a click does nothing. */
      [[[a buttons] objectAtIndex: 0] performClick: nil];
      PASS(YES, "a click when the alert is not running is harmless");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSAlert buttons")
  return 0;
}
