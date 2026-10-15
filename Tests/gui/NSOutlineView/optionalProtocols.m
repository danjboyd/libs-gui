/* As in Cocoa, the methods of NSOutlineViewDataSource and
   NSOutlineViewDelegate are optional, so a class that adopts the protocol
   implements only those it needs (a Swift class must otherwise implement
   them all).  An outline view works with a data source that implements
   only the methods to supply the items.  The view needs the backend, so
   that part is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableColumn.h>
#include <objc/runtime.h>

@interface MinimalTree : NSObject <NSOutlineViewDataSource>
@end

@implementation MinimalTree
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
@end

static BOOL
isOptional(Protocol *p, SEL sel)
{
  struct objc_method_description	req;
  struct objc_method_description	opt;

  req = protocol_getMethodDescription(p, sel, YES, YES);
  opt = protocol_getMethodDescription(p, sel, NO, YES);
  return req.name == NULL && opt.name != NULL;
}

int
main(int argc, const char **argv)
{
  START_SET("NSOutlineView optional protocol methods")
  Protocol	*ds = @protocol(NSOutlineViewDataSource);
  Protocol	*del = @protocol(NSOutlineViewDelegate);

  PASS(isOptional(ds, @selector(outlineView:numberOfChildrenOfItem:))
    && isOptional(ds, @selector(outlineView:child:ofItem:))
    && isOptional(ds, @selector(outlineView:isItemExpandable:))
    && isOptional(ds, @selector(outlineView:objectValueForTableColumn:byItem:)),
    "the data source methods supplying items are optional");
  PASS(isOptional(ds, @selector(outlineView:acceptDrop:item:childIndex:))
    && isOptional(ds, @selector(outlineView:persistentObjectForItem:))
    && isOptional(ds, @selector(outlineView:writeItems:toPasteboard:)),
    "the other data source methods are optional");
  PASS(isOptional(del, @selector(outlineView:willDisplayCell:forTableColumn:item:))
    && isOptional(del, @selector(outlineViewSelectionDidChange:))
    && isOptional(del, @selector(outlineView:shouldExpandItem:)),
    "the delegate methods are optional");
  PASS([MinimalTree conformsToProtocol: ds],
    "a data source with only some methods conforms");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSOutlineView	*ov = AUTORELEASE([[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn	*col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"c"]);
      MinimalTree	*tree = AUTORELEASE([MinimalTree new]);

      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      [ov setDataSource: tree];
      [ov reloadData];
      PASS([ov numberOfRows] == 2 && [[ov itemAtRow: 1] isEqual: @"B"],
        "an outline view shows the items of a minimal data source");
      [ov reloadItem: @"B"];
      PASS([[ov itemAtRow: 1] isEqual: @"B"], "and reloads an item");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOutlineView optional protocol methods")
  return 0;
}
