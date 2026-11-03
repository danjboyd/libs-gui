/* +[NSStatusBar systemStatusBar] answers the same status bar every time,
   and that bar makes status items that know it, as on Cocoa.  It used to
   answer nil.  The bar's items are not displayed without a system tray,
   and the bar needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSStatusBar.h>
#include <AppKit/NSStatusItem.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSStatusBar *bar;
  NSStatusItem *item;

  START_SET("NSStatusBar systemStatusBar")

  bar = [NSStatusBar systemStatusBar];
  PASS(bar != nil, "there is a system status bar");
  PASS([NSStatusBar systemStatusBar] == bar, "it is shared");
  PASS([bar thickness] > 0 && ![bar isVertical],
    "it is a horizontal bar with a thickness");
  item = [bar statusItemWithLength: 88.0];
  PASS(item != nil && [item statusBar] == bar,
    "it makes status items that know their bar");
  [bar removeStatusItem: item];

  END_SET("NSStatusBar systemStatusBar")

  [pool release];
  return 0;
}
