/* The delegate's -outlineView:willDisplayCell:forTableColumn:item: sees
   the cell holding the value of the item being drawn.  It used to be sent
   before the value was set, so it saw the previous row's value.  Drawing
   needs the backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableColumn.h>

@interface WDCTree : NSObject
{
@public
  NSMutableArray *seen;
}
@end

@implementation WDCTree
- (NSInteger) outlineView: (NSOutlineView *)ov numberOfChildrenOfItem: (id)item
{
  return item == nil ? 3 : 0;
}
- (id) outlineView: (NSOutlineView *)ov child: (NSInteger)i ofItem: (id)item
{
  return [[NSArray arrayWithObjects: @"A", @"B", @"C", nil] objectAtIndex: i];
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
  START_SET("NSOutlineView willDisplayCell")

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
      NSOutlineView *ov = AUTORELEASE([[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"c"]);
      WDCTree *tree = AUTORELEASE([WDCTree new]);
      NSArray *expected = [NSArray arrayWithObjects:
        @"A=vA", @"B=vB", @"C=vC", nil];

      tree->seen = [NSMutableArray array];
      [col setWidth: 100.0];
      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      [ov setDataSource: tree];
      [ov setDelegate: tree];
      [ov reloadData];
      [w setContentView: ov];

      [ov lockFocus];
      [ov drawRect: [ov bounds]];
      [ov unlockFocus];
      PASS_EQUAL(tree->seen, expected,
        "willDisplayCell: sees each item's own value when drawing");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOutlineView willDisplayCell")
  return 0;
}
