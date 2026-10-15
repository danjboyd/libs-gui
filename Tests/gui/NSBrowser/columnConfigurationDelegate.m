/* A browser posts NSBrowserColumnConfigurationDidChangeNotification when
   a column's width is set, and its delegate is told of it, as a window's
   delegate is told of its notifications.  The browser posted nothing, and
   -setDelegate: did not register the delegate.  The
   browser uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSNotification.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSBrowser.h>
#include <AppKit/NSBrowserCell.h>

@interface ConfigDelegate : NSObject
{
@public
  int count;
}
@end

@implementation ConfigDelegate
- (NSInteger) browser: (NSBrowser *)sender numberOfRowsInColumn: (NSInteger)column
{
  return 0;
}
- (void) browser: (NSBrowser *)sender
  willDisplayCell: (id)cell
            atRow: (NSInteger)row
           column: (NSInteger)column
{
}
- (void) browserColumnConfigurationDidChange: (NSNotification *)n
{
  count++;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSBrowser *browser;
  ConfigDelegate *d;

  START_SET("NSBrowser column configuration delegate")

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

  d = AUTORELEASE([ConfigDelegate new]);
  browser = AUTORELEASE([[NSBrowser alloc]
    initWithFrame: NSMakeRect(0, 0, 300, 200)]);
  [browser setDelegate: d];
  [browser setWidth: 120 ofColumn: 0];
  PASS(d->count == 1, "setting a column width tells the delegate");

  [browser setDelegate: nil];
  [browser setWidth: 100 ofColumn: 0];
  PASS(d->count == 1, "a former delegate is no longer told");

  END_SET("NSBrowser column configuration delegate")

  [pool release];
  return 0;
}
