/* -selectNextTabViewItem: on the last item and -selectPreviousTabViewItem:
   on the first item leave the selection alone, as AppKit does.  They used
   to select the item at an index past either end, which selected nothing. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSView.h>
#include <AppKit/NSTabView.h>
#include <AppKit/NSTabViewItem.h>

static NSTabViewItem *
mk(NSString *ident)
{
  NSTabViewItem *it = AUTORELEASE([[NSTabViewItem alloc]
    initWithIdentifier: ident]);
  [it setLabel: ident];
  [it setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 50, 50)])];
  return it;
}

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTabView *tv;
  NSTabViewItem *a, *b;

  START_SET("NSTabView selection at the ends")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTabView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 200)]);
  a = mk(@"a");
  b = mk(@"b");
  [tv addTabViewItem: a];
  [tv addTabViewItem: b];

  [tv selectLastTabViewItem: nil];
  [tv selectNextTabViewItem: nil];
  PASS([tv selectedTabViewItem] == b,
    "selectNextTabViewItem: on the last item keeps it selected");

  [tv selectFirstTabViewItem: nil];
  [tv selectPreviousTabViewItem: nil];
  PASS([tv selectedTabViewItem] == a,
    "selectPreviousTabViewItem: on the first item keeps it selected");

  END_SET("NSTabView selection at the ends")

  [pool release];
  return 0;
}
