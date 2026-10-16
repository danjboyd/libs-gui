/* A table view whose delegate implements tableView:heightOfRow: gives each
   row the height the delegate answers, in -rectOfRow:, -rowAtPoint: and
   the height of the table.  The delegate method used to be ignored, so
   every row had the table's row height.  The table needs the backend, so
   the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableView.h>

@interface HeightSource : NSObject
@end

@implementation HeightSource
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
- (CGFloat) tableView: (NSTableView *)tv heightOfRow: (NSInteger)row
{
  return 10.0 + 15.0 * row;	/* 10, 25, 40 */
}
@end

int
main(int argc, const char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSTableView *tv;
  HeightSource *source;
  NSRect r;

  START_SET("NSTableView heightOfRow")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)]);
  [tv addTableColumn: AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"c"])];
  source = AUTORELEASE([HeightSource new]);
  [tv setDataSource: (id<NSTableViewDataSource>)source];
  [tv setDelegate: (id<NSTableViewDelegate>)source];
  [tv reloadData];

  r = [tv rectOfRow: 0];
  PASS(NSMinY(r) == 0 && NSHeight(r) == 10, "the first row has its own height");
  r = [tv rectOfRow: 1];
  PASS(NSMinY(r) == 10 && NSHeight(r) == 25,
       "the second row starts below the first and has its own height");
  r = [tv rectOfRow: 2];
  PASS(NSMinY(r) == 35 && NSHeight(r) == 40,
       "the third row starts below the second and has its own height");
  PASS([tv rowAtPoint: NSMakePoint(5, 20)] == 1
       && [tv rowAtPoint: NSMakePoint(5, 70)] == 2,
       "rowAtPoint: finds the rows by their heights");
  [tv sizeToFit];
  [tv tile];
  PASS(NSHeight([tv frame]) >= 75, "the table is as high as its rows");

  END_SET("NSTableView heightOfRow")

  DESTROY(arp);
  return 0;
}
