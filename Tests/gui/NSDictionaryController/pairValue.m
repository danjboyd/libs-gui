/* A key-value pair keeps the value it is given, as Cocoa's strong value
   property does, so a mutable value stays the same object and a value that
   cannot be copied can be set.  The value used to be copied.  Key-value
   pairs need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>

#include <AppKit/NSDictionaryController.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSDictionaryController *dc;
  NSDictionaryControllerKeyValuePair *kvp;
  NSMutableArray *value = [NSMutableArray arrayWithObject: @"x"];
  id plain = AUTORELEASE([NSObject new]);

  START_SET("NSDictionaryControllerKeyValuePair value")

  dc = AUTORELEASE([[NSDictionaryController alloc]
    initWithContent: [NSMutableDictionary dictionary]]);
  kvp = AUTORELEASE([dc newObject]);

  [kvp setValue: value];
  PASS([kvp value] == value, "the pair keeps the value object itself");
  PASS_RUNS([kvp setValue: plain],
    "a value that cannot be copied can be set");
  PASS([kvp value] == plain, "the pair keeps a value that cannot be copied");

  END_SET("NSDictionaryControllerKeyValuePair value")

  [pool release];
  return 0;
}
