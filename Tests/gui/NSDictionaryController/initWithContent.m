/* -[NSDictionaryController initWithContent:] keeps the dictionary it is
   given, so the controller arranges one key-value pair per entry.  It used
   to set the content and then reset it to an empty dictionary.  */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>

#include <AppKit/NSDictionaryController.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSDictionaryController *dc;
  NSMutableDictionary *content;
  NSArray *pairs;

  START_SET("NSDictionaryController initWithContent")

  content = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    @"1-alpha", @"a", @"2-beta", @"b", @"3-gamma", @"c", nil];
  dc = AUTORELEASE([[NSDictionaryController alloc] initWithContent: content]);
  [dc rearrangeObjects];
  pairs = [dc arrangedObjects];
  PASS([pairs count] == 3, "the controller arranges one pair per entry");
  PASS([[[pairs objectAtIndex: 0] key] isEqual: @"a"]
    && [[[pairs objectAtIndex: 2] value] isEqual: @"3-gamma"],
    "the pairs hold the content's keys and values");
  PASS([[dc initialKey] isEqual: @"key"],
    "the other properties still have their defaults");

  END_SET("NSDictionaryController initWithContent")

  [pool release];
  return 0;
}
