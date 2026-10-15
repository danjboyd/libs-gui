/* A browser keeps its background colour and whether it autohides its
   scroller, and answers the column and row of the last click.  These were
   stubs: the setters dropped the values, the colour was always the control
   colour, and the click location was always -1.  The browser uses the
   theme and font backend, so the set is skipped when the backend is
   unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSBrowser.h>
#include <AppKit/NSBrowserCell.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSMatrix.h>

@interface StateContent : NSObject
@end

@implementation StateContent
- (NSInteger) browser: (NSBrowser *)sender numberOfRowsInColumn: (NSInteger)column
{
  return column == 0 ? 3 : 0;
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
  StateContent *content;
  NSColor *red;

  START_SET("NSBrowser stored state")

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

  content = AUTORELEASE([StateContent new]);
  browser = AUTORELEASE([[NSBrowser alloc]
    initWithFrame: NSMakeRect(0, 0, 300, 200)]);
  [browser setDelegate: content];
  [browser loadColumnZero];

  red = [NSColor redColor];
  [browser setBackgroundColor: red];
  PASS([browser backgroundColor] == red, "the background colour is kept");
  PASS([[browser matrixInColumn: 0] backgroundColor] == red,
    "the loaded columns take the background colour");

  [browser setAutohidesScroller: YES];
  PASS([browser autohidesScroller], "autohiding the scroller is kept");

  PASS([browser clickedColumn] == -1 && [browser clickedRow] == -1,
    "there is no click location before a click");
  [browser selectRow: 1 inColumn: 0];
  [browser doClick: [browser matrixInColumn: 0]];
  PASS([browser clickedColumn] == 0 && [browser clickedRow] == 1,
    "the click location is that of the last click");

  END_SET("NSBrowser stored state")

  [pool release];
  return 0;
}
