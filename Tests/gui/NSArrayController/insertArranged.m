/* -insertObject:atArrangedObjectIndex: and
   -insertObjects:atArrangedObjectIndexes: put the objects at the given
   arranged indexes.  They used to append them, as -addObject: does. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSIndexSet.h>
#include <Foundation/NSString.h>

#include <AppKit/NSArrayController.h>

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSArrayController *ac;
  NSMutableArray *content;
  NSMutableIndexSet *indexes;
  NSArray *expected;

  START_SET("NSArrayController insertArranged")

  content = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", nil];
  ac = AUTORELEASE([[NSArrayController alloc] initWithContent: content]);
  [ac setSelectsInsertedObjects: NO];
  [ac setSelectionIndex: 1];	/* b */

  [ac insertObject: @"x" atArrangedObjectIndex: 1];
  expected = [NSArray arrayWithObjects: @"a", @"x", @"b", @"c", nil];
  PASS([[ac arrangedObjects] isEqual: expected],
       "insertObject:atArrangedObjectIndex: inserts at the index");
  PASS([[ac content] isEqual: expected], "the content has the object there too");
  PASS([[[ac selectedObjects] lastObject] isEqual: @"b"],
       "the selected object stays selected");

  [ac insertObject: @"z" atArrangedObjectIndex: 4];
  PASS([[[ac arrangedObjects] lastObject] isEqual: @"z"],
       "inserting at the count appends");

  indexes = [NSMutableIndexSet indexSet];
  [indexes addIndex: 0];
  [indexes addIndex: 2];
  [ac insertObjects: [NSArray arrayWithObjects: @"p", @"q", nil]
    atArrangedObjectIndexes: indexes];
  expected = [NSArray arrayWithObjects:
    @"p", @"a", @"q", @"x", @"b", @"c", @"z", nil];
  PASS([[ac arrangedObjects] isEqual: expected],
       "insertObjects:atArrangedObjectIndexes: puts each object at its index");

  END_SET("NSArrayController insertArranged")

  DESTROY(arp);
  return 0;
}
