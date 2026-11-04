/* A copy of an NSPopUpButtonCell has its own menu, so a menu keeps its owner
   when a copy goes away.  NSTableView tracks a copy of its data cell and
   releases it afterwards.  In the Windows 95 menu style a top level menu with
   no owner is never shown, so a table's popup used to open only once. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSUserDefaults.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSMenuItem.h>
#include <AppKit/NSPopUpButtonCell.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>

static NSPopUpButtonCell *
popup(void)
{
  NSPopUpButtonCell *c;

  c = AUTORELEASE([[NSPopUpButtonCell alloc] initTextCell: @"" pullsDown: NO]);
  [c addItemsWithTitles: [NSArray arrayWithObjects: @"a", @"b", @"c", nil]];
  return c;
}

int
main(int argc, char **argv)
{
  NSPopUpButtonCell *cell;
  NSPopUpButtonCell *copy;
  NSPopUpButtonCell *other;
  NSMenu *menu;

  START_SET("NSPopUpButtonCell copy")

  /* The style is read when a menu window is ordered front. */
  [[NSUserDefaults standardUserDefaults] registerDefaults:
    [NSDictionary dictionaryWithObject: @"NSWindows95InterfaceStyle"
                                forKey: @"NSMenuInterfaceStyle"]];

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  cell = popup();
  [cell selectItemAtIndex: 1];
  menu = [cell menu];
  PASS([menu _owningPopUp] == cell, "a cell owns its menu");

  copy = [cell copy];
  PASS([copy menu] != menu, "a copy has its own menu");
  PASS([[copy menu] _owningPopUp] == copy, "the copy owns its menu");
  PASS([menu _owningPopUp] == cell, "copying leaves the original's owner alone");
  PASS([copy numberOfItems] == 3
    && [[copy itemTitleAtIndex: 2] isEqual: @"c"], "the copy has the same items");
  PASS([copy indexOfSelectedItem] == 1, "the copy has the same selection");

  [copy selectItemAtIndex: 2];
  PASS([cell indexOfSelectedItem] == 1,
    "selecting in the copy leaves the original alone");
  [copy addItemWithTitle: @"d"];
  PASS([cell numberOfItems] == 3, "changing the copy's menu leaves the original");

  RELEASE(copy);
  PASS([cell menu] == menu && [menu _owningPopUp] == cell,
    "the menu keeps its owner when the copy is released");

  /* A cell that no longer owns the menu it holds must not clear the owner. */
  other = popup();
  [other setMenu: menu];
  PASS([menu _owningPopUp] == other, "the last cell given a menu owns it");
  [cell setMenu: nil];
  PASS([menu _owningPopUp] == other,
    "a cell that isn't the owner leaves the owner alone");
  [other setMenu: nil];
  PASS([menu _owningPopUp] == nil, "the owner clears itself");

  NS_DURING
    {
      NSWindow *w;
      int i;
      BOOL allShown = YES;

      w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 200, 100)
                  styleMask: NSTitledWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      [w orderFront: nil];
      cell = popup();
      for (i = 0; i < 2; i++)
        {
          copy = [cell copy];
          [copy attachPopUpWithFrame: NSMakeRect(10, 10, 100, 20)
                              inView: [w contentView]];
          allShown = allShown && [[[copy menu] window] isVisible];
          [copy dismissPopUp];
          RELEASE(copy);
        }
      PASS(allShown, "each copy's list opens in the Windows 95 style");
      [cell attachPopUpWithFrame: NSMakeRect(10, 10, 100, 20)
                          inView: [w contentView]];
      PASS([[[cell menu] window] isVisible],
        "the original's list still opens after its copies are gone");
      [cell dismissPopUp];
      [w orderOut: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSPopUpButtonCell copy")

  return 0;
}
