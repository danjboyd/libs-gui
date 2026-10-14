/* The NSTreeController insertion actions: -add: adds an object at the end of
   the top level, -addChild: and -insertChild: add a child to the selected
   object, and -insert: inserts a sibling at the selection.  -addChild:,
   -insertChild: and -insert: used to all insert a sibling at the
   selection. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSString.h>

#include <AppKit/NSTreeController.h>

static NSMutableDictionary *
item(NSString *name)
{
  return [NSMutableDictionary dictionaryWithObjectsAndKeys:
    name, @"name", [NSMutableArray array], @"children", nil];
}

static NSTreeController *
controller(NSMutableArray *content)
{
  NSTreeController *tc;

  [content addObject: item(@"one")];
  [content addObject: item(@"two")];
  [content addObject: item(@"three")];
  tc = [[NSTreeController alloc] initWithContent: content];
  [tc setChildrenKeyPath: @"children"];
  return AUTORELEASE(tc);
}

static NSUInteger
childCount(id object)
{
  return [[object objectForKey: @"children"] count];
}

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSIndexPath *selection = [NSIndexPath indexPathWithIndex: 1];
  NSMutableArray *content;
  NSTreeController *tc;
  id two;

  START_SET("NSTreeController actions")

  content = [NSMutableArray array];
  tc = controller(content);
  two = [content objectAtIndex: 1];
  [tc add: nil];
  PASS([content count] == 4 && [content objectAtIndex: 1] == two
    && [[content objectAtIndex: 3] objectForKey: @"name"] == nil,
    "add: adds a new object at the end of the top level");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  two = [content objectAtIndex: 1];
  [tc setSelectionIndexPath: selection];
  [tc addChild: nil];
  PASS([content count] == 3 && childCount(two) == 1,
    "addChild: adds a child to the selected object");
  [tc addChild: nil];
  PASS([content count] == 3 && childCount(two) == 2,
    "addChild: appends to the children of the selected object");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  two = [content objectAtIndex: 1];
  [tc setSelectionIndexPath: selection];
  [tc insertChild: nil];
  PASS([content count] == 3 && childCount(two) == 1,
    "insertChild: adds a child to the selected object");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  two = [content objectAtIndex: 1];
  [tc setSelectionIndexPath: selection];
  [tc insert: nil];
  PASS([content count] == 4 && [content objectAtIndex: 2] == two
    && childCount(two) == 0,
    "insert: inserts a sibling at the selection");
  [tc setContent: nil];

  END_SET("NSTreeController actions")

  [pool release];
  return 0;
}
