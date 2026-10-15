/* -preparedCellAtColumn:row: answers the cell set up for the row: it holds
   the row's object value and the delegate has been sent willDisplayCell:
   for it.  The same holds for an outline view, whose delegate is sent
   -outlineView:willDisplayCell:forTableColumn:item:.  It used to answer
   the column's data cell as it was.  Creating the views needs the backend,
   so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTableColumn.h>

@interface PCSource : NSObject
{
@public
  NSMutableArray *seen;
}
@end

@implementation PCSource
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tv
{
  return 3;
}
- (id) tableView: (NSTableView *)tv
  objectValueForTableColumn: (NSTableColumn *)col
	      row: (NSInteger)row
{
  return [NSString stringWithFormat: @"r%ld", (long)row];
}
- (void) tableView: (NSTableView *)tv
   willDisplayCell: (id)cell
    forTableColumn: (NSTableColumn *)col
	       row: (NSInteger)row
{
  [seen addObject: [NSString stringWithFormat: @"%ld=%@",
    (long)row, [cell objectValue]]];
}

- (NSInteger) outlineView: (NSOutlineView *)ov numberOfChildrenOfItem: (id)item
{
  return item == nil ? 2 : 0;
}
- (id) outlineView: (NSOutlineView *)ov child: (NSInteger)i ofItem: (id)item
{
  return i == 0 ? @"A" : @"B";
}
- (BOOL) outlineView: (NSOutlineView *)ov isItemExpandable: (id)item
{
  return NO;
}
- (id) outlineView: (NSOutlineView *)ov
  objectValueForTableColumn: (NSTableColumn *)col
	    byItem: (id)item
{
  return [@"v" stringByAppendingString: item];
}
- (void) outlineView: (NSOutlineView *)ov
     willDisplayCell: (id)cell
      forTableColumn: (NSTableColumn *)col
		item: (id)item
{
  [seen addObject: [NSString stringWithFormat: @"%@=%@",
    item, [cell objectValue]]];
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSTableView preparedCell")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSTableView *tv = AUTORELEASE([[NSTableView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSOutlineView *ov = AUTORELEASE([[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"a"]);
      NSTableColumn *ocol = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"o"]);
      PCSource *src = AUTORELEASE([PCSource new]);
      NSCell *cell;

      src->seen = [NSMutableArray array];
      [tv addTableColumn: col];
      [tv setDataSource: src];
      [tv setDelegate: src];
      [tv reloadData];

      cell = [tv preparedCellAtColumn: 0 row: 1];
      PASS_EQUAL([cell objectValue], @"r1",
        "the prepared cell holds the row's object value");
      PASS_EQUAL(src->seen, [NSArray arrayWithObject: @"1=r1"],
        "the delegate is sent willDisplayCell: with the value set");
      cell = [tv preparedCellAtColumn: 0 row: 2];
      PASS_EQUAL([cell objectValue], @"r2",
        "another row's prepared cell holds that row's value");

      [src->seen removeAllObjects];
      cell = [tv preparedCellAtColumn: 0 row: 3];
      PASS(cell != nil && [src->seen count] == 0,
        "a row past the end gives the cell without asking for a value");

      [src->seen removeAllObjects];
      [ov addTableColumn: ocol];
      [ov setOutlineTableColumn: ocol];
      [ov setDataSource: src];
      [ov setDelegate: src];
      [ov reloadData];
      cell = [ov preparedCellAtColumn: 0 row: 1];
      PASS_EQUAL([cell objectValue], @"vB",
        "an outline view's prepared cell holds the item's value");
      PASS_EQUAL(src->seen, [NSArray arrayWithObject: @"B=vB"],
        "the outline view's delegate is sent willDisplayCell: for the item");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSTableView preparedCell")
  return 0;
}
