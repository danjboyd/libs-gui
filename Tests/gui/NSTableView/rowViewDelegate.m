/* A view-based table view tells its delegate tableView:didAddRowView:forRow:
   for each row view it adds when it displays its rows, and
   tableView:didRemoveRowView:forRow: for each row view it removes when
   it reloads.  Neither delegate method was sent.  The table needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableRowView.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSWindow.h>

static NSString *cellXib =
  @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  @"<document type=\"com.apple.InterfaceBuilder3.Cocoa.XIB\" version=\"3.0\" "
  @"toolsVersion=\"14490.70\" targetRuntime=\"MacOSX.Cocoa\" "
  @"propertyAccessControl=\"none\">\n"
  @"    <objects>\n"
  @"        <customObject id=\"-2\" userLabel=\"File's Owner\"/>\n"
  @"        <customObject id=\"-1\" userLabel=\"First Responder\" "
  @"customClass=\"FirstResponder\"/>\n"
  @"        <customObject id=\"-3\" userLabel=\"Application\" "
  @"customClass=\"NSObject\"/>\n"
  @"        <customView id=\"cell-view\">\n"
  @"            <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"60\" "
  @"height=\"17\"/>\n"
  @"        </customView>\n"
  @"    </objects>\n"
  @"</document>";

@interface RowSource : NSObject
{
@public
  NSInteger rows;
  NSMutableArray *added;
  NSMutableArray *removed;
  BOOL hadCellView;
}
@end

@implementation RowSource
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tv
{
  return rows;
}
- (NSView *) tableView: (NSTableView *)tv
    viewForTableColumn: (NSTableColumn *)col
                   row: (NSInteger)row
{
  return AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 60, 17)]);
}
- (void) tableView: (NSTableView *)tv
     didAddRowView: (NSTableRowView *)rowView
            forRow: (NSInteger)row
{
  if ([[rowView subviews] count] > 0)
    {
      hadCellView = YES;
    }
  [added addObject: [NSNumber numberWithInteger: row]];
}
- (void) tableView: (NSTableView *)tv
  didRemoveRowView: (NSTableRowView *)rowView
            forRow: (NSInteger)row
{
  if ([rowView superview] == nil)
    {
      [removed addObject: [NSNumber numberWithInteger: row]];
    }
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSTableView row view delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 220, 160)
                  styleMask: NSBorderlessWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSScrollView *scroll = AUTORELEASE([[NSScrollView alloc]
        initWithFrame: NSMakeRect(10, 10, 200, 140)]);
      NSTableView *table = AUTORELEASE([[NSTableView alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 100)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"cell"]);
      RowSource *source = AUTORELEASE([RowSource new]);
      NSData *data = [cellXib dataUsingEncoding: NSUTF8StringEncoding];
      NSArray *all = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0],
        [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], nil];

      source->rows = 3;
      source->added = [NSMutableArray array];
      source->removed = [NSMutableArray array];
      [col setWidth: 100];
      [table addTableColumn: col];
      [table registerNib: AUTORELEASE([[NSNib alloc] initWithNibData: data
                                                              bundle: nil])
           forIdentifier: @"cell"];
      [table setDataSource: source];
      [table setDelegate: source];
      [scroll setDocumentView: table];
      [[w contentView] addSubview: scroll];
      [w orderFront: nil];
      [w display];
      PASS([source->added isEqual: all],
        "the delegate is told of each row view added");

      [source->added removeAllObjects];
      [table reloadData];
      [w display];
      PASS([source->removed isEqual: all] && [source->added isEqual: all],
        "reloading removes the row views and adds new ones");
      PASS(source->hadCellView, "a row view is added with its cell views");
      [source->added removeAllObjects];
      [w display];
      PASS([source->added count] == 0,
        "a row view already shown is not added again");

      source->rows = 0;
      [source->removed removeAllObjects];
      [table reloadData];
      [w display];
      PASS([source->removed isEqual: all],
        "the delegate is told of each row view removed");
      [table setDelegate: nil];
      [table setDataSource: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSTableView row view delegate")

  DESTROY(arp);
  return 0;
}
