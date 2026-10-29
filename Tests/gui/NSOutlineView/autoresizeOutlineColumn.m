/* An NSOutlineView that autoresizes its outline column widens the column
   when it draws rows that do not fit: the widest row's cell, with its
   indentation and disclosure image.  The column then keeps that width on
   the next draw.  -drawRect: used to measure the rows but never set the
   width.
   The outline view uses the theme and font backend, so the set is skipped
   when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCell.h>
#include <AppKit/NSOutlineView.h>
#include <AppKit/NSTableColumn.h>
#include <AppKit/NSWindow.h>

/* A two-level tree whose leaf has a long title.  */
@interface Tree : NSObject
@end

@implementation Tree
- (NSInteger) outlineView: (NSOutlineView *)ov numberOfChildrenOfItem: (id)item
{
  if (item == nil || [item isEqual: @"parent"])
    return 1;
  return 0;
}
- (id) outlineView: (NSOutlineView *)ov child: (NSInteger)index ofItem: (id)item
{
  if (item == nil)
    return @"parent";
  return @"a leaf with a title much wider than the column";
}
- (BOOL) outlineView: (NSOutlineView *)ov isItemExpandable: (id)item
{
  return [item isEqual: @"parent"];
}
- (id) outlineView: (NSOutlineView *)ov
  objectValueForTableColumn: (NSTableColumn *)col
            byItem: (id)item
{
  return item;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSOutlineView *ov;
  NSTableColumn *col;
  NSWindow *window;
  Tree *ds;
  CGFloat width;

  START_SET("NSOutlineView autoresizes the outline column")

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

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 400, 200)
	      styleMask: NSBorderlessWindowMask
		backing: NSBackingStoreBuffered
		  defer: NO]);
  [window setReleasedWhenClosed: NO];
  ds = AUTORELEASE([[Tree alloc] init]);
  ov = AUTORELEASE([[NSOutlineView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 200)]);
  col = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"c"]);
  [col setWidth: 40.0];
  [ov addTableColumn: col];
  [ov setOutlineTableColumn: col];
  /* Keep the table from sizing its columns to its width.  */
  [ov setColumnAutoresizingStyle: NSTableViewNoColumnAutoresizing];
  /* Outline views autoresize the outline column by default.  */
  [ov setAutoresizesOutlineColumn: NO];
  [ov setDataSource: ds];
  [[window contentView] addSubview: ov];
  [ov reloadData];
  [ov expandItem: @"parent"];
  [window orderFrontRegardless];

  [window display];
  PASS([col width] == 40.0,
    "a column that does not autoresize keeps its width");

  [ov setAutoresizesOutlineColumn: YES];
  [window display];
  width = [col width];
  PASS(width > 40.0, "an autoresizing outline column widens to its rows");
  PASS(width >= [[ov preparedCellAtColumn: 0 row: 1] cellSize].width
    + [ov indentationPerLevel],
    "the column fits the indented widest row");
  [window display];
  PASS([col width] == width, "the column keeps its width on the next draw");

  END_SET("NSOutlineView autoresizes the outline column")

  [pool release];
  return 0;
}
