/* -removeSelectionIndexPaths: takes the paths out of the selection and
   leaves the content alone.  It used to remove the objects at the paths
   from the arranged tree instead. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSString.h>

#include <AppKit/NSTreeController.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSIndexPath *first = [NSIndexPath indexPathWithIndex: 0];
  NSIndexPath *last = [NSIndexPath indexPathWithIndex: 2];
  NSMutableArray *content;
  NSTreeController *tc;
  BOOL removed;

  START_SET("NSTreeController removeSelectionIndexPaths:")

  content = [NSMutableArray arrayWithObjects:
    [NSMutableDictionary dictionary],
    [NSMutableDictionary dictionary],
    [NSMutableDictionary dictionary], nil];
  tc = AUTORELEASE([[NSTreeController alloc] initWithContent: content]);
  [tc setChildrenKeyPath: @"children"];
  [tc setSelectionIndexPaths: [NSArray arrayWithObjects: first, last, nil]];

  removed = [tc removeSelectionIndexPaths: [NSArray arrayWithObject: first]];
  PASS(removed == YES, "removeSelectionIndexPaths: answers YES");
  PASS([content count] == 3, "removeSelectionIndexPaths: keeps the content");
  PASS([[tc selectionIndexPaths] count] == 1
    && [[tc selectionIndexPath] isEqual: last],
    "removeSelectionIndexPaths: deselects the paths");

  [tc setContent: nil];

  END_SET("NSTreeController removeSelectionIndexPaths:")

  [pool release];
  return 0;
}
