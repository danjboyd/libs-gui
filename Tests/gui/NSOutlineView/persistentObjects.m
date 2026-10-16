/* An outline view that autosaves its expanded items saves the objects its
   data source gives for them with outlineView:persistentObjectForItem:,
   and restores them by expanding the items the data source gives for the
   saved objects with outlineView:itemForPersistentObject:.  The items
   themselves used to be saved and expanded, without asking the data
   source.  The outline view needs the backend, so the set is skipped
   without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSTableColumn.h>

/* Items that are not property lists, so only their names can be saved. */
@interface Node : NSObject
{
@public
  NSString *name;
  NSArray *children;
}
@end

@implementation Node
@end

@interface Tree : NSObject
{
@public
  Node *root[2];
  NSMutableArray *persisted;
  NSMutableArray *restored;
}
@end

@implementation Tree
- (NSInteger) outlineView: (NSOutlineView *)ov numberOfChildrenOfItem: (id)item
{
  return item == nil ? 2 : [((Node *)item)->children count];
}
- (id) outlineView: (NSOutlineView *)ov child: (NSInteger)i ofItem: (id)item
{
  return item == nil ? root[i] : [((Node *)item)->children objectAtIndex: i];
}
- (BOOL) outlineView: (NSOutlineView *)ov isItemExpandable: (id)item
{
  return [((Node *)item)->children count] > 0;
}
- (id) outlineView: (NSOutlineView *)ov
  objectValueForTableColumn: (NSTableColumn *)col
	    byItem: (id)item
{
  return ((Node *)item)->name;
}
- (id) outlineView: (NSOutlineView *)ov persistentObjectForItem: (id)item
{
  [persisted addObject: item];
  return ((Node *)item)->name;
}
- (id) outlineView: (NSOutlineView *)ov itemForPersistentObject: (id)object
{
  [restored addObject: object];
  return [object isEqual: root[0]->name] ? root[0]
    : ([object isEqual: root[1]->name] ? root[1] : nil);
}
@end

static Node *
node(NSString *name, NSArray *children)
{
  Node *n = AUTORELEASE([Node new]);

  n->name = name;
  n->children = children;
  return n;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSOutlineView persistent objects")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSString *savedKey = @"NSOutlineView Expanded Items PersistSaved";
      NSString *restoredKey = @"NSOutlineView Expanded Items PersistRestored";
      NSOutlineView *ov = AUTORELEASE([[NSOutlineView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 80)]);
      NSTableColumn *col = AUTORELEASE([[NSTableColumn alloc]
        initWithIdentifier: @"c"]);
      Tree *tree = AUTORELEASE([Tree new]);
      Node *leaf = node(@"leaf", nil);

      tree->root[0] = node(@"alpha", [NSArray arrayWithObject: leaf]);
      tree->root[1] = node(@"beta", [NSArray arrayWithObject: node(@"b", nil)]);
      tree->persisted = [NSMutableArray array];
      tree->restored = [NSMutableArray array];
      [defaults removeObjectForKey: savedKey];
      [defaults setObject: [NSArray arrayWithObject: @"beta"]
                   forKey: restoredKey];

      [ov addTableColumn: col];
      [ov setOutlineTableColumn: col];
      [ov setDataSource: tree];
      [ov reloadData];
      [ov setAutosaveExpandedItems: YES];
      [ov setAutosaveName: @"PersistSaved"];
      [ov expandItem: tree->root[0]];
      PASS([tree->persisted indexOfObjectIdenticalTo: tree->root[0]] != NSNotFound,
        "the data source is asked for the persistent object of an expanded item");
      PASS_EQUAL([defaults arrayForKey: savedKey],
        [NSArray arrayWithObject: @"alpha"],
        "the persistent objects of the expanded items are saved");

      [ov setAutosaveName: @"PersistRestored"];
      PASS([tree->restored containsObject: @"beta"],
        "the data source is asked for the item of a saved object");
      PASS([ov isItemExpanded: tree->root[1]],
        "the item of a saved object is expanded");

      [ov setAutosaveExpandedItems: NO];
      [defaults removeObjectForKey: savedKey];
      [defaults removeObjectForKey: restoredKey];
      [ov setDataSource: nil];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOutlineView persistent objects")

  DESTROY(arp);
  return 0;
}
