/* NSAlert copies a button's hasDestructiveAction to the panel's own button, so
   a theme sees the flag on the button it draws.  The panel is only set up to
   run, so a timer inspects it during the modal session and ends the session.
   Running the alert needs a backend, so the set is skipped when the backend is
   unavailable. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSRunLoop.h>
#include <Foundation/NSString.h>

#include <AppKit/NSAlert.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSPanel.h>
#include <AppKit/NSView.h>

static NSButton *
findButton(NSView *view, NSString *title)
{
  NSEnumerator *e = [[view subviews] objectEnumerator];
  NSView *v;

  while ((v = [e nextObject]) != nil)
    {
      NSButton *found;

      if ([v isKindOfClass: [NSButton class]]
        && [[(NSButton*)v title] isEqual: title])
        {
          return (NSButton*)v;
        }
      found = findButton(v, title);
      if (found != nil)
        {
          return found;
        }
    }
  return nil;
}

@interface Inspector : NSObject
{
@public
  BOOL inspected;
  BOOL hasOwnDelete;
  BOOL deleteDestructive;
  BOOL keepDestructive;
}
@end

@implementation Inspector
- (void) inspect: (NSAlert *)alert
{
  NSView *content = [[alert window] contentView];
  NSButton *delete = findButton(content, @"Delete");
  NSButton *keep = findButton(content, @"Keep");

  inspected = YES;
  hasOwnDelete = (delete != nil
    && delete != [[alert buttons] objectAtIndex: 0]);
  deleteDestructive = [delete hasDestructiveAction];
  keepDestructive = (keep == nil || [keep hasDestructiveAction]);
  [NSApp stopModalWithCode: 0];
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
@end

int
main(int argc, char **argv)
{
  START_SET("NSAlert destructive button")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSArray *modes = [NSArray arrayWithObject: NSModalPanelRunLoopMode];
      Inspector *inspector = AUTORELEASE([Inspector new]);
      NSAlert *alert = AUTORELEASE([NSAlert new]);

      [alert setMessageText: @"Delete the file?"];
      [[alert addButtonWithTitle: @"Delete"] setHasDestructiveAction: YES];
      [alert addButtonWithTitle: @"Keep"];

      [inspector performSelector: @selector(inspect:)
                      withObject: alert
                      afterDelay: 0.1
                         inModes: modes];
      [alert runModal];

      PASS(inspector->inspected, "the panel was inspected while running");
      PASS(inspector->hasOwnDelete, "the panel has its own Delete button");
      PASS(inspector->deleteDestructive,
        "the panel's Delete button is destructive");
      PASS(inspector->keepDestructive == NO,
        "the panel's Keep button is not");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSAlert destructive button")

  return 0;
}
