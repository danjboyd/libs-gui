/* A status bar releases a status item it no longer holds.  Each item was
   the represented object of its own menu item, which retained it, so no
   status item was ever deallocated.  A status bar made with -init needs no
   backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSStatusBar.h>
#include <AppKit/NSStatusItem.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSAutoreleasePool *inner;
  NSStatusBar *bar;
  NSStatusItem *item;

  START_SET("NSStatusBar removeStatusItem:")

  bar = AUTORELEASE([[NSStatusBar alloc] init]);
  inner = [NSAutoreleasePool new];
  item = RETAIN([bar statusItemWithLength: NSVariableStatusItemLength]);
  [inner release];

  PASS([item retainCount] == 2,
    "the status bar holds the only other reference to its item");
  [bar removeStatusItem: item];
  PASS([item retainCount] == 1,
    "removing the item releases it");
  RELEASE(item);

  END_SET("NSStatusBar removeStatusItem:")

  [pool release];
  return 0;
}
