/* Resizing a column of an outline view posts
   NSOutlineViewColumnDidResizeNotification, which is how the outline view's
   delegate learns of it through outlineViewColumnDidResize:.  The table
   column used to post only NSTableViewColumnDidResizeNotification, which the
   outline view's delegate is not registered for.  Both notifications name
   the column and its old width.
   The view uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSNotification.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSOutlineView.h>
#include <AppKit/NSTableColumn.h>

@interface Delegate : NSObject
{
@public
  NSNotification *outline;
  NSNotification *table;
}
@end
@implementation Delegate
- (void) dealloc
{
  RELEASE(outline);
  RELEASE(table);
  [super dealloc];
}
- (void) outlineViewColumnDidResize: (NSNotification *)n
{
  ASSIGN(outline, n);
}
- (void) tableResized: (NSNotification *)n
{
  ASSIGN(table, n);
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSOutlineView *ov;
  NSTableColumn *column;
  Delegate *delegate;

  START_SET("NSOutlineView column resize")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  delegate = AUTORELEASE([Delegate new]);
  ov = AUTORELEASE([[NSOutlineView alloc]
    initWithFrame: NSMakeRect(0, 0, 300, 200)]);
  column = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"c"]);
  [column setWidth: 100];
  [ov addTableColumn: column];
  [ov setDelegate: delegate];
  [[NSNotificationCenter defaultCenter]
    addObserver: delegate
       selector: @selector(tableResized:)
	   name: NSTableViewColumnDidResizeNotification
	 object: ov];

  [column setWidth: 150];
  PASS(delegate->outline != nil,
    "the outline view's delegate is told about the resize");
  PASS([delegate->outline object] == ov,
    "the outline view posts the notification");
  PASS([[delegate->outline userInfo] objectForKey: @"NSTableColumn"] == column,
    "the notification names the column");
  PASS([[[delegate->outline userInfo] objectForKey: @"NSOldWidth"]
    floatValue] == 100,
    "the notification gives the old width");
  PASS(delegate->table != nil
    && [[delegate->table userInfo] objectForKey: @"NSTableColumn"] == column,
    "the table view notification is still posted");

  [[NSNotificationCenter defaultCenter] removeObserver: delegate];
  [ov setDelegate: nil];

  END_SET("NSOutlineView column resize")

  [pool release];
  return 0;
}
