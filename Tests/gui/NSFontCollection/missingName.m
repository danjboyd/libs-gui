/* +fontCollectionWithName: answers nil for a name no collection has been
 * saved under, as documented, for both the immutable and the mutable class,
 * but always answers the standard collections.  It used to make a new
 * empty collection for any name.  Looking up a
 * collection needs no font backend.
 */
#include "Testing.h"
#include <Foundation/Foundation.h>
#include <AppKit/NSFontCollection.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSString *name = @"GSTestNoSuchFontCollection";

  START_SET("missing font collection name")
    PASS([NSFontCollection fontCollectionWithName: name] == nil,
      "no collection is found for an unknown name");
    PASS([NSFontCollection fontCollectionWithName: name
      visibility: NSFontCollectionVisibilityProcess] == nil,
      "no collection is found for an unknown name and visibility");
    PASS([NSMutableFontCollection fontCollectionWithName: name] == nil,
      "no mutable collection is found for an unknown name");
    PASS([NSFontCollection fontCollectionWithName: NSFontCollectionUser] != nil,
      "the user collection is always found");
    PASS([NSFontCollection fontCollectionWithName: NSFontCollectionFavorites]
      != nil, "the favorites collection is always found");
    PASS([NSFontCollection fontCollectionWithName: NSFontCollectionRecentlyUsed]
      != nil, "the recently used collection is always found");
  END_SET("missing font collection name")

  [pool release];
  return 0;
}
