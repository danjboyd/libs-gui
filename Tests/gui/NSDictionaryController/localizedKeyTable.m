/* A dictionary controller reads its localized key table as a strings file,
   so the table -setLocalizedKeyDictionary: writes can be set back, and the
   keys of the pairs are localized from it.  The table was parsed as a
   property list, which rejects strings file text, so the dictionary came
   out nil.  Dictionary controllers need no backend. */
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
  NSDictionary *names;
  NSString *table;
  NSDictionaryControllerKeyValuePair *kvp;

  START_SET("NSDictionaryController localizedKeyTable")

  names = [NSDictionary dictionaryWithObjectsAndKeys:
    @"Beta", @"b", @"Say \"hi\"", @"q", nil];
  dc = AUTORELEASE([[NSDictionaryController alloc] init]);
  [dc setContent: [NSMutableDictionary dictionaryWithObject: @"2"
                                                     forKey: @"b"]];

  [dc setLocalizedKeyDictionary: names];
  table = [dc localizedKeyTable];
  PASS(table != nil, "a localized key dictionary gives a table");

  [dc setLocalizedKeyDictionary: nil];
  [dc setLocalizedKeyTable: table];
  PASS_EQUAL([dc localizedKeyDictionary], names,
    "the table it wrote reads back as the same dictionary");

  [dc setLocalizedKeyTable: @"\"b\" = \"Bravo\";\n"];
  PASS_EQUAL([[dc localizedKeyDictionary] objectForKey: @"b"], @"Bravo",
    "a strings file table sets the dictionary");
  kvp = [[dc arrangedObjects] lastObject];
  PASS_EQUAL([kvp localizedKey], @"Bravo",
    "the pair's key is localized from the table");

  END_SET("NSDictionaryController localizedKeyTable")

  [pool release];
  return 0;
}
