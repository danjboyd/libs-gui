/* NSButton -hasDestructiveAction: the flag is off by default, round trips on
   the button and its cell, leaves other cell state alone, and survives copying
   the cell and keyed archiving. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSKeyedArchiver.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSButtonCell.h>

int
main(int argc, char **argv)
{
  NSButton *b;
  NSButtonCell *c;
  NSButtonCell *copy;
  NSData *data;

  START_SET("NSButton hasDestructiveAction")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  b = AUTORELEASE([[NSButton alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 40)]);
  c = [b cell];

  PASS([b hasDestructiveAction] == NO, "a button is not destructive by default");
  [c setAllowsMixedState: YES];
  [b setHasDestructiveAction: YES];
  PASS([b hasDestructiveAction] == YES, "the flag round-trips on the button");
  PASS([c hasDestructiveAction] == YES, "the cell carries the button's flag");
  PASS([c allowsMixedState] == YES, "other cell state is left alone");

  copy = AUTORELEASE([c copy]);
  PASS([copy hasDestructiveAction] == YES, "a copy of the cell keeps the flag");

  data = [NSKeyedArchiver archivedDataWithRootObject: c];
  copy = [NSKeyedUnarchiver unarchiveObjectWithData: data];
  PASS([copy hasDestructiveAction] == YES, "a keyed archive keeps the flag");

  [b setHasDestructiveAction: NO];
  PASS([b hasDestructiveAction] == NO, "the flag can be cleared");
  data = [NSKeyedArchiver archivedDataWithRootObject: c];
  copy = [NSKeyedUnarchiver unarchiveObjectWithData: data];
  PASS([copy hasDestructiveAction] == NO, "a keyed archive keeps a clear flag");

  END_SET("NSButton hasDestructiveAction")

  return 0;
}
