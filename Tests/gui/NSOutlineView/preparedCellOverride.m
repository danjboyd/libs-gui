/* A subclass that overrides -preparedCellAtColumn:row: customises the
   cells the outline view draws, as in Cocoa: drawing a row uses the
   override, does not undo what it set, and the delegate is told about
   each cell once.  Drawing needs the backend, so the set is skipped
   without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSTextFieldCell.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableColumn.h>

static NSMutableArray	*drawn = nil;

/* Records the value it is drawn with. */
@interface RecordingCell : NSTextFieldCell
@end

@implementation RecordingCell
- (void) drawWithFrame: (NSRect)frame inView: (NSView *)view
{
  [drawn addObject: [self stringValue]];
}
@end

@interface PrefixingOutlineView : NSOutlineView
{
@public
  int	prepared;
}
@end

@implementation PrefixingOutlineView
- (NSCell *) preparedCellAtColumn: (NSInteger)column row: (NSInteger)row
{
  NSCell	*cell = [super preparedCellAtColumn: column row: row];

  prepared++;
  [cell setStringValue:
    [@"custom-" stringByAppendingString: [cell stringValue]]];
  return cell;
}
@end

@interface PCOTree : NSObject
{
@public
  int	willDisplay;
}
@end

@implementation PCOTree
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
  return item;
}
- (void) outlineView: (NSOutlineView *)ov
     willDisplayCell: (id)cell
      forTableColumn: (NSTableColumn *)col
		item: (id)item
{
  willDisplay++;
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSOutlineView preparedCell override")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow	*w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 120, 80)
                  styleMask: NSWindowStyleMaskBorderless
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      PrefixingOutlineView	*ov = AUTORELEASE([[PrefixingOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn	*col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"c"]);
      PCOTree		*tree = AUTORELEASE([PCOTree new]);

      drawn = [NSMutableArray array];
      [col setWidth: 100.0];
      [col setDataCell: AUTORELEASE([RecordingCell new])];
      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      [ov setDataSource: tree];
      [ov setDelegate: tree];
      [ov reloadData];
      [w setContentView: ov];

      ov->prepared = 0;
      tree->willDisplay = 0;
      [ov lockFocus];
      [ov drawRect: [ov bounds]];
      [ov unlockFocus];
      PASS(ov->prepared == 2, "drawing uses the overriding method");
      PASS_EQUAL(drawn, ([NSArray arrayWithObjects:
        @"custom-A", @"custom-B", nil]),
        "the cells are drawn as the override set them up");
      PASS(tree->willDisplay == 2, "the delegate is told of each cell once");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOutlineView preparedCell override")
  return 0;
}
