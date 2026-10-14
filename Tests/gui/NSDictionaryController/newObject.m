/* -newObject belongs to the "new" method family, so the caller owns the
   key-value pair it returns, and -add: and -insert: release the pair once
   they have added it.  The pair used to be autoreleased as well, so it was
   released once too often and freed while the controller still held it.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSKeyValueCoding.h>
#include <Foundation/NSString.h>

#include <AppKit/NSDictionaryController.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSAutoreleasePool *inner;
  NSDictionaryController *dc;
  NSDictionaryControllerKeyValuePair *kvp;

  START_SET("NSDictionaryController newObject")

  dc = AUTORELEASE([[NSDictionaryController alloc]
    initWithContent: [NSMutableDictionary dictionary]]);

  inner = [NSAutoreleasePool new];
  kvp = [dc newObject];
  [inner release];
  PASS([kvp retainCount] == 1,
    "newObject returns a key-value pair the caller owns");
  RELEASE(kvp);

  inner = [NSAutoreleasePool new];
  [dc add: nil];
  [inner release];
  PASS([[dc arrangedObjects] count] == 1, "add: adds a key-value pair");
  PASS([[[dc arrangedObjects] valueForKey: @"key"]
    containsObject: @"key1"],
    "the added key-value pair is still valid");

  inner = [NSAutoreleasePool new];
  [dc insert: nil];
  [inner release];
  PASS([[dc arrangedObjects] count] == 2, "insert: adds a key-value pair");
  PASS([[[dc arrangedObjects] valueForKey: @"key"]
    containsObject: @"key2"],
    "the inserted key-value pair is still valid");

  END_SET("NSDictionaryController newObject")

  [pool release];
  return 0;
}
