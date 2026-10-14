/* A title with no ampersand gives a menu item no mnemonic.
   -setTitleWithMnemonic: passed NSNotFound on as the mnemonic location, and
   -mnemonic then raised taking a character at that location. */
#import "Testing.h"

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <AppKit/NSMenuItem.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMenuItem *item;
  NSString *mnemonic = @"unset";

  START_SET("NSMenuItem mnemonic")

  item = AUTORELEASE([[NSMenuItem alloc] init]);
  [item setTitleWithMnemonic: @"&Open"];
  PASS_EQUAL([item title], @"Open", "the ampersand is taken out of the title");
  PASS([item mnemonicLocation] == 0, "the mnemonic location is recorded");
  PASS_EQUAL([item mnemonic], @"O", "the mnemonic is the marked character");

  [item setTitleWithMnemonic: @"Close"];
  PASS([item mnemonicLocation] == NSNotFound,
    "a title without an ampersand gives no mnemonic location");
  PASS_RUNS(mnemonic = [item mnemonic],
    "mnemonic does not raise for a title without an ampersand");
  PASS_EQUAL(mnemonic, @"", "a title without an ampersand gives no mnemonic");

  [item setMnemonicLocation: 9];
  PASS_EQUAL([item mnemonic], @"",
    "a mnemonic location past the end of the title gives no mnemonic");

  END_SET("NSMenuItem mnemonic")

  [pool release];
  return 0;
}
