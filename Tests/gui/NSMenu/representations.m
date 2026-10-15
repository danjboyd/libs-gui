/* A menu keeps the context and tear-off menu representations it is given.
   Both setters were stubs and the getters answered nil.  Menus need no
   backend for this. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSMenu.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMenu *menu;
  id context = AUTORELEASE([NSObject new]);
  id tearOff = AUTORELEASE([NSObject new]);

  START_SET("NSMenu representations")

  menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Test"]);
  PASS([menu contextMenuRepresentation] == nil
    && [menu tearOffMenuRepresentation] == nil,
    "a new menu has no context or tear-off representation");
  [menu setContextMenuRepresentation: context];
  [menu setTearOffMenuRepresentation: tearOff];
  PASS([menu contextMenuRepresentation] == context,
    "the context menu representation is kept");
  PASS([menu tearOffMenuRepresentation] == tearOff,
    "the tear-off menu representation is kept");

  END_SET("NSMenu representations")

  [pool release];
  return 0;
}
