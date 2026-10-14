/* A menu tells its delegate when it opens and closes, as an ordinary or a
   transient menu, or as the menu of a pop-up button, once each time.
   Neither menuWillOpen: nor menuDidClose: was ever sent.  Displaying a menu needs the backend, so the set is
   skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSPopUpButton.h>
#include <AppKit/NSPopUpButtonCell.h>
#include <AppKit/NSWindow.h>

@interface OpenCloseDelegate : NSObject
{
@public
  int willOpen;
  int didClose;
}
@end

@implementation OpenCloseDelegate
- (void) menuWillOpen: (NSMenu *)menu
{
  willOpen++;
}
- (void) menuDidClose: (NSMenu *)menu
{
  didClose++;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  OpenCloseDelegate *d;
  NSMenu *menu;
  NSWindow *window;
  NSPopUpButton *button;
  NSPopUpButtonCell *cell;

  START_SET("NSMenu open and close delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  d = AUTORELEASE([OpenCloseDelegate new]);
  menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Test"]);
  [menu addItemWithTitle: @"Item" action: NULL keyEquivalent: @""];
  [menu setDelegate: d];

  [menu display];
  [menu display];
  PASS(d->willOpen == 1, "displaying a menu tells the delegate once");
  [menu close];
  [menu close];
  PASS(d->didClose == 1, "closing a menu tells the delegate once");

  [menu displayTransient];
  PASS(d->willOpen == 2, "displaying a transient menu tells the delegate");
  [menu closeTransient];
  PASS(d->didClose == 2, "closing a transient menu tells the delegate");

  [menu setDelegate: nil];

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 200, 100)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  button = AUTORELEASE([[NSPopUpButton alloc]
    initWithFrame: NSMakeRect(10, 10, 120, 24) pullsDown: NO]);
  [[window contentView] addSubview: button];
  [button addItemWithTitle: @"One"];
  [button addItemWithTitle: @"Two"];
  cell = [button cell];
  d = AUTORELEASE([OpenCloseDelegate new]);
  [[cell menu] setDelegate: d];
  [cell attachPopUpWithFrame: [button bounds] inView: button];
  PASS(d->willOpen == 1 && d->didClose == 0,
    "popping up a pop-up button's menu tells the delegate it opens");
  [cell dismissPopUp];
  PASS(d->willOpen == 1 && d->didClose == 1,
    "dismissing a pop-up button's menu tells the delegate it closed");
  [[cell menu] setDelegate: nil];

  END_SET("NSMenu open and close delegate")

  [pool release];
  return 0;
}
