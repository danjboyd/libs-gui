/* NSButtonCell keeps the location of its alternate title's mnemonic. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSKeyedArchiver.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSButtonCell.h>

int
main(int argc, char **argv)
{
  NSButtonCell *cell;
  NSButtonCell *copy;

  START_SET("NSButtonCell alternate mnemonic")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  cell = AUTORELEASE([[NSButtonCell alloc] initTextCell: @"Title"]);
  PASS([cell alternateMnemonicLocation] == NSNotFound,
    "there is no alternate mnemonic by default");
  PASS_EQUAL([cell alternateMnemonic], @"", "the default mnemonic is empty");

  [cell setAlternateTitleWithMnemonic: @"Al&ternate"];
  PASS_EQUAL([cell alternateTitle], @"Alternate", "the & leaves the title");
  PASS([cell alternateMnemonicLocation] == 2, "the & gives the location");
  PASS_EQUAL([cell alternateMnemonic], @"t", "the mnemonic is that character");

  [cell setAlternateMnemonicLocation: 3];
  PASS([cell alternateMnemonicLocation] == 3, "the location can be set");
  PASS_EQUAL([cell alternateMnemonic], @"e", "the mnemonic follows it");

  copy = AUTORELEASE([cell copy]);
  PASS([copy alternateMnemonicLocation] == 3, "a copy keeps the location");

  [cell setAlternateMnemonicLocation: 20];
  PASS_EQUAL([cell alternateMnemonic], @"",
    "a location past the end has no mnemonic");

  [cell setAlternateMnemonicLocation: NSNotFound];
  PASS([cell alternateMnemonicLocation] == NSNotFound,
    "NSNotFound removes the mnemonic");

  [cell setAlternateTitleWithMnemonic: @"Plain"];
  PASS([cell alternateMnemonicLocation] == NSNotFound,
    "a title with no & has no mnemonic");

  END_SET("NSButtonCell alternate mnemonic")

  return 0;
}
