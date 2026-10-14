/* Editing an NSTreeController through arranged-object index paths changes
   its content, so the edits survive -rearrangeObjects, which rebuilds the
   arranged tree from the content.  The edits used to change a copy of the
   top level held by the arranged tree, and were lost. */
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

static NSIndexPath *
path1(NSUInteger i)
{
  return [NSIndexPath indexPathWithIndex: i];
}

static NSIndexPath *
path2(NSUInteger i, NSUInteger j)
{
  return [path1(i) indexPathByAddingIndex: j];
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
arrangedCount(NSTreeController *tc)
{
  return [[[tc arrangedObjects] childNodes] count];
}

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMutableArray *content;
  NSTreeController *tc;
  id inserted;
  id one;

  START_SET("NSTreeController editing")

  content = [NSMutableArray array];
  tc = controller(content);
  inserted = item(@"inserted");
  [tc insertObject: inserted atArrangedObjectIndexPath: path1(1)];
  PASS([content count] == 4 && [content objectAtIndex: 1] == inserted,
    "inserting at a top-level path inserts into the content at that index");
  PASS(arrangedCount(tc) == 4, "the arranged tree holds the inserted object");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  one = [content objectAtIndex: 0];
  inserted = item(@"child");
  [tc insertObject: inserted atArrangedObjectIndexPath: path2(0, 0)];
  PASS([content count] == 3
    && [[one objectForKey: @"children"] count] == 1
    && [[one objectForKey: @"children"] objectAtIndex: 0] == inserted,
    "inserting at a nested path inserts into the children of the parent");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  [tc insertObjects: [NSArray arrayWithObjects: item(@"a"), item(@"b"), nil]
    atArrangedObjectIndexPaths: [NSArray arrayWithObjects:
      path1(0), path1(1), nil]];
  PASS([content count] == 5
    && [[[content objectAtIndex: 0] objectForKey: @"name"] isEqual: @"a"]
    && [[[content objectAtIndex: 1] objectForKey: @"name"] isEqual: @"b"],
    "inserting several objects inserts each at its path");
  PASS(arrangedCount(tc) == 5, "the arranged tree holds the inserted objects");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  [tc removeObjectAtArrangedObjectIndexPath: path1(0)];
  PASS([content count] == 2
    && [[[content objectAtIndex: 0] objectForKey: @"name"] isEqual: @"two"],
    "removing at a path removes the object from the content");
  PASS(arrangedCount(tc) == 2, "the arranged tree loses the removed object");
  [tc setContent: nil];

  content = [NSMutableArray array];
  tc = controller(content);
  [tc removeObjectsAtArrangedObjectIndexPaths:
    [NSArray arrayWithObjects: path1(0), path1(2), nil]];
  PASS([content count] == 1
    && [[[content objectAtIndex: 0] objectForKey: @"name"] isEqual: @"two"],
    "removing several paths removes the object at each path");
  [tc setContent: nil];

  END_SET("NSTreeController editing")

  [pool release];
  return 0;
}
