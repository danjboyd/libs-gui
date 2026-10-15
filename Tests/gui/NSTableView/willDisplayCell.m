/* The delegate's -tableView:willDisplayCell:forTableColumn:row: sees the
   cell holding the value of the row being drawn, so it can style cells by
   their value.  It used to be sent before the value was set, so it saw the
   previous row's value.  Drawing needs the backend, so the set is skipped
   without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTableColumn.h>

@interface WDCSource : NSObject
{
@public
  NSMutableArray *seen;
}
@end

@implementation WDCSource
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
@end

int
main(int argc, const char **argv)
{
  START_SET("NSTableView willDisplayCell")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 120, 80)
                  styleMask: NSWindowStyleMaskBorderless
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSTableView *tv = AUTORELEASE([[NSTableView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"a"]);
      WDCSource *src = AUTORELEASE([WDCSource new]);
      NSArray *expected = [NSArray arrayWithObjects:
        @"0=r0", @"1=r1", @"2=r2", nil];

      src->seen = [NSMutableArray array];
      [col setWidth: 100.0];
      [tv addTableColumn: col];
      [tv setDataSource: src];
      [tv setDelegate: src];
      [tv reloadData];
      [w setContentView: tv];

      [tv lockFocus];
      [tv drawRect: [tv bounds]];
      [tv unlockFocus];
      PASS_EQUAL(src->seen, expected,
        "willDisplayCell: sees each row's own value when drawing");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSTableView willDisplayCell")
  return 0;
}
