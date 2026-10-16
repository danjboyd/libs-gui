/* A view-based outline view tells its delegate
   outlineView:didAddRowView:forRow: for each row view it adds when it
   displays its rows, as after expanding an item, and
   outlineView:didRemoveRowView:forRow: for each row view it removes, as
   when an item is collapsed.  Neither delegate method was sent.  The
   outline view needs the backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableRowView.h>
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

@interface RowTree : NSObject
{
@public
  NSMutableArray *added;
  NSMutableArray *removed;
}
@end

@implementation RowTree
- (NSInteger) outlineView: (NSOutlineView *)ov numberOfChildrenOfItem: (id)item
{
  return item == nil ? 2 : ([item isEqual: @"parent"] ? 1 : 0);
}
- (id) outlineView: (NSOutlineView *)ov child: (NSInteger)i ofItem: (id)item
{
  if (item == nil)
    {
      return i == 0 ? @"parent" : @"other";
    }
  return @"child";
}
- (BOOL) outlineView: (NSOutlineView *)ov isItemExpandable: (id)item
{
  return [item isEqual: @"parent"];
}
- (NSView *) outlineView: (NSOutlineView *)ov
      viewForTableColumn: (NSTableColumn *)col
                    item: (id)item
{
  return AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 60, 17)]);
}
- (void) outlineView: (NSOutlineView *)ov
       didAddRowView: (NSTableRowView *)rowView
              forRow: (NSInteger)row
{
  [added addObject: [NSNumber numberWithInteger: row]];
}
- (void) outlineView: (NSOutlineView *)ov
    didRemoveRowView: (NSTableRowView *)rowView
              forRow: (NSInteger)row
{
  [removed addObject: [NSNumber numberWithInteger: row]];
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSOutlineView row view delegate")

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
      NSOutlineView *ov = AUTORELEASE([[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 100)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"cell"]);
      RowTree *tree = AUTORELEASE([RowTree new]);
      NSData *data = [cellXib dataUsingEncoding: NSUTF8StringEncoding];
      NSNumber *one = [NSNumber numberWithInt: 1];

      tree->added = [NSMutableArray array];
      tree->removed = [NSMutableArray array];
      [col setWidth: 100];
      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      [ov registerNib: AUTORELEASE([[NSNib alloc] initWithNibData: data
                                                           bundle: nil])
        forIdentifier: @"cell"];
      [ov setDataSource: tree];
      [ov setDelegate: tree];
      [scroll setDocumentView: ov];
      [[w contentView] addSubview: scroll];
      [w orderFront: nil];
      [w display];
      PASS([tree->added count] == 2,
        "the delegate is told of the row views first shown");

      [tree->added removeAllObjects];
      [ov expandItem: @"parent"];
      [w display];
      PASS([tree->added containsObject: one],
        "the delegate is told of the row view of an expanded child");

      [ov collapseItem: @"parent"];
      [w display];
      PASS([tree->removed containsObject: one],
        "the delegate is told of the row views removed on collapsing");
      [ov setDelegate: nil];
      [ov setDataSource: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOutlineView row view delegate")

  DESTROY(arp);
  return 0;
}
