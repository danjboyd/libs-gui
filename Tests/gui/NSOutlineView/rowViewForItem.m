/* A view-based outline view asks its delegate outlineView:rowViewForItem:
   for the row view of an item, and uses the row view the delegate
   returns; it makes a plain NSTableRowView when the delegate returns
   nil.  The outline view used to ask only tableView:rowViewForRow:,
   which an outline view delegate does not implement.  The outline view
   needs the backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableRowView.h>

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

@interface RowTree : NSObject
{
@public
  NSTableRowView *rowView;
  NSMutableArray *asked;
}
@end

@implementation RowTree
- (NSInteger) outlineView: (NSOutlineView *)ov numberOfChildrenOfItem: (id)item
{
  return item == nil ? 2 : 0;
}
- (id) outlineView: (NSOutlineView *)ov child: (NSInteger)i ofItem: (id)item
{
  return i == 0 ? @"first" : @"second";
}
- (BOOL) outlineView: (NSOutlineView *)ov isItemExpandable: (id)item
{
  return NO;
}
- (id) outlineView: (NSOutlineView *)ov
  objectValueForTableColumn: (NSTableColumn *)col
	    byItem: (id)item
{
  return item;
}
- (NSTableRowView *) outlineView: (NSOutlineView *)ov
                  rowViewForItem: (id)item
{
  [asked addObject: item];
  return [item isEqual: @"first"] ? rowView : nil;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSOutlineView rowViewForItem")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSOutlineView *ov = AUTORELEASE([[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"cell"]);
      RowTree *tree = AUTORELEASE([RowTree new]);
      NSData *data = [cellXib dataUsingEncoding: NSUTF8StringEncoding];
      NSTableRowView *other;

      tree->rowView = AUTORELEASE([NSTableRowView new]);
      tree->asked = [NSMutableArray array];
      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      [ov registerNib: AUTORELEASE([[NSNib alloc] initWithNibData: data
                                                           bundle: nil])
        forIdentifier: @"cell"];
      [ov setDataSource: tree];
      [ov setDelegate: tree];
      [ov reloadData];

      PASS([ov rowViewAtRow: 0 makeIfNecessary: YES] == tree->rowView,
        "the row view of an item is the one the delegate returns");
      PASS([tree->asked isEqual: [NSArray arrayWithObject: @"first"]],
        "the delegate is asked with the row's item");
      other = [ov rowViewAtRow: 1 makeIfNecessary: YES];
      PASS([other isKindOfClass: [NSTableRowView class]]
        && other != tree->rowView,
        "a row view is made when the delegate returns nil");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOutlineView rowViewForItem")

  DESTROY(arp);
  return 0;
}
