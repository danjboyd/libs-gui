/* -moveNode:toIndexPath: and -moveNodes:toIndexPath: move the objects the
   nodes represent within the content: the objects are taken out of their
   places, then placed one after the other from the given path on.  Both
   methods used to do nothing. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSString.h>

#include <AppKit/NSTreeController.h>
#include <AppKit/NSTreeNode.h>

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

  [content addObject: item(@"a")];
  [content addObject: item(@"b")];
  [content addObject: item(@"c")];
  [content addObject: item(@"d")];
  tc = [[NSTreeController alloc] initWithContent: content];
  [tc setChildrenKeyPath: @"children"];
  return AUTORELEASE(tc);
}

static NSString *
names(NSArray *objects)
{
  return [[objects valueForKey: @"name"] componentsJoinedByString: @""];
}

static NSTreeNode *
node(id object)
{
  return [NSTreeNode treeNodeWithRepresentedObject: object];
}

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMutableArray *content;
  NSTreeController *tc;
  id a;
  id b;
  id c;

  START_SET("NSTreeController moveNodes")

  content = [NSMutableArray array];
  tc = controller(content);
  a = [content objectAtIndex: 0];
  [tc moveNode: node(a) toIndexPath: [NSIndexPath indexPathWithIndex: 2]];
  PASS_EQUAL(names(content), @"bcad", "moveNode: moves an object later");
  [tc moveNode: node(a) toIndexPath: [NSIndexPath indexPathWithIndex: 0]];
  PASS_EQUAL(names(content), @"abcd", "moveNode: moves an object earlier");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  a = [content objectAtIndex: 0];
  b = [content objectAtIndex: 1];
  [tc moveNodes: [NSArray arrayWithObjects: node(a), node(b), nil]
    toIndexPath: [NSIndexPath indexPathWithIndex: 2]];
  PASS_EQUAL(names(content), @"cdab",
    "moveNodes: places the objects one after the other");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  b = [content objectAtIndex: 1];
  c = [content objectAtIndex: 2];
  [tc moveNode: node(c)
   toIndexPath: [[NSIndexPath indexPathWithIndex: 1] indexPathByAddingIndex: 0]];
  PASS_EQUAL(names(content), @"abd", "moveNode: takes the object out");
  PASS_EQUAL(names([b objectForKey: @"children"]), @"c",
    "moveNode: moves an object to a nested path");
  [tc moveNode: node(c)
   toIndexPath: [[NSIndexPath indexPathWithIndex: 9] indexPathByAddingIndex: 0]];
  PASS_EQUAL(names([b objectForKey: @"children"]), @"c",
    "moveNode: leaves the object in place for a path that leads nowhere");
  [tc setContent: nil];

  END_SET("NSTreeController moveNodes")

  [pool release];
  return 0;
}
