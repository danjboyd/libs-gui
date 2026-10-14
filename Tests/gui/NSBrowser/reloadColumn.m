/* -reloadColumn: reselects the rows that were selected in the column, if
   they remain.  It looked the old cells up in the reloaded column, whose
   cells are new, so the selection was lost.  The browser uses the theme and
   font backend, so the set is skipped when the backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSBrowser.h>
#include <AppKit/NSBrowserCell.h>

@interface ReloadContent : NSObject
{
@public
  NSInteger rows;
}
@end

@implementation ReloadContent
- (NSInteger) browser: (NSBrowser *)sender numberOfRowsInColumn: (NSInteger)column
{
  return column == 0 ? rows : 0;
}
- (void) browser: (NSBrowser *)sender
  willDisplayCell: (id)cell
            atRow: (NSInteger)row
           column: (NSInteger)column
{
  [cell setStringValue: [NSString stringWithFormat: @"r%ld", (long)row]];
  [cell setLeaf: YES];
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSBrowser *browser;
  ReloadContent *content;

  START_SET("NSBrowser reloadColumn:")

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

  content = AUTORELEASE([ReloadContent new]);
  content->rows = 3;
  browser = AUTORELEASE([[NSBrowser alloc]
    initWithFrame: NSMakeRect(0, 0, 300, 200)]);
  [browser setDelegate: content];
  [browser loadColumnZero];

  [browser selectRow: 1 inColumn: 0];
  [browser reloadColumn: 0];
  PASS([browser selectedRowInColumn: 0] == 1,
    "reloadColumn: reselects the selected row");

  [browser selectRow: 2 inColumn: 0];
  content->rows = 2;
  [browser reloadColumn: 0];
  PASS([browser selectedRowInColumn: 0] == -1,
    "reloadColumn: does not reselect a row that is gone");

  END_SET("NSBrowser reloadColumn:")

  [pool release];
  return 0;
}
