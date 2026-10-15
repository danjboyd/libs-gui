/* A scroll view keeps whether it allows magnification, whether it adjusts
   its content insets automatically (YES by default, as in Cocoa), and its
   content and scroller insets, and keyed archives keep them.  The setters were stubs that dropped the
   values.  The scroll view needs the backend, so the set is skipped
   without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSScrollView.h>
#include <Foundation/NSKeyedArchiver.h>

static BOOL
sameInsets(NSEdgeInsets a, NSEdgeInsets b)
{
  return a.top == b.top && a.left == b.left
    && a.bottom == b.bottom && a.right == b.right;
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSScrollView *sv;
  NSEdgeInsets content = NSEdgeInsetsMake(1, 2, 3, 4);
  NSEdgeInsets scroller = NSEdgeInsetsMake(5, 6, 7, 8);

  START_SET("NSScrollView insets and magnification")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  sv = AUTORELEASE([[NSScrollView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 100)]);
  PASS([sv allowsMagnification] == NO, "magnification is off by default");
  PASS([sv automaticallyAdjustsContentInsets] == YES,
    "content insets are adjusted automatically by default");

  [sv setAllowsMagnification: YES];
  [sv setAutomaticallyAdjustsContentInsets: NO];
  [sv setContentInsets: content];
  [sv setScrollerInsets: scroller];
  PASS([sv allowsMagnification] == YES, "magnification can be allowed");
  PASS([sv automaticallyAdjustsContentInsets] == NO,
    "automatic content insets can be turned off");
  PASS(sameInsets([sv contentInsets], content), "the content insets are kept");
  PASS(sameInsets([sv scrollerInsets], scroller), "the scroller insets are kept");

  {
    NSScrollView *decoded = [NSKeyedUnarchiver unarchiveObjectWithData:
      [NSKeyedArchiver archivedDataWithRootObject: sv]];

    PASS([decoded allowsMagnification] == YES
      && [decoded automaticallyAdjustsContentInsets] == NO
      && sameInsets([decoded contentInsets], content)
      && sameInsets([decoded scrollerInsets], scroller),
      "keyed archiving keeps the magnification and inset state");
  }

  END_SET("NSScrollView insets and magnification")

  [pool release];
  return 0;
}
