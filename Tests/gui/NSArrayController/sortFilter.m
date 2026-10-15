/* Setting an array controller's sort descriptors or filter predicate
   rearranges its objects at once, as in Cocoa, and observers of
   arrangedObjects are told.  They used to be stored only, so the arranged
   objects kept their old order and contents until -rearrangeObjects. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSKeyValueObserving.h>
#include <Foundation/NSPredicate.h>
#include <Foundation/NSSortDescriptor.h>
#include <Foundation/NSString.h>

#include <AppKit/NSArrayController.h>

@interface SFObserver : NSObject
{
@public
  int changes;
}
@end

@implementation SFObserver
- (void) observeValueForKeyPath: (NSString *)path
		       ofObject: (id)object
			 change: (NSDictionary *)change
			context: (void *)context
{
  changes++;
}
@end

int main()
{
  START_SET("NSArrayController sort and filter")
  NSArrayController *ac;
  NSMutableArray *content;
  SFObserver *obs;
  NSSortDescriptor *sd;
  NSArray *arranged;

  content = [NSMutableArray arrayWithObjects:
    @"charlie", @"alpha", @"bravo", nil];
  ac = AUTORELEASE([[NSArrayController alloc] initWithContent: content]);
  obs = AUTORELEASE([SFObserver new]);
  PASS([[ac arrangedObjects] count] == 3, "the content is arranged");
  [ac addObserver: obs forKeyPath: @"arrangedObjects" options: 0 context: 0];

  sd = AUTORELEASE([[NSSortDescriptor alloc]
    initWithKey: @"self" ascending: YES selector: @selector(compare:)]);
  [ac setSortDescriptors: [NSArray arrayWithObject: sd]];
  arranged = [ac arrangedObjects];
  PASS_EQUAL(arranged, ([NSArray arrayWithObjects:
    @"alpha", @"bravo", @"charlie", nil]),
    "setting the sort descriptors sorts the arranged objects");
  PASS(obs->changes > 0, "observers of arrangedObjects are told of the sort");

  obs->changes = 0;
  [ac setFilterPredicate:
    [NSPredicate predicateWithFormat: @"SELF BEGINSWITH 'b'"]];
  PASS_EQUAL([ac arrangedObjects], [NSArray arrayWithObject: @"bravo"],
    "setting the filter predicate filters the arranged objects");
  PASS(obs->changes > 0, "observers of arrangedObjects are told of the filter");

  [ac setFilterPredicate: nil];
  PASS([[ac arrangedObjects] count] == 3,
    "clearing the filter predicate brings the objects back");
  PASS_EQUAL([[ac arrangedObjects] objectAtIndex: 0], @"alpha",
    "and they are still sorted");

  [ac removeObserver: obs forKeyPath: @"arrangedObjects"];
  END_SET("NSArrayController sort and filter")
  return 0;
}
