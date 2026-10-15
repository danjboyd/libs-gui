/* Scrubber layout attributes keep the item index, frame and alpha (1 by
   default) they are given, and copies keep them.  The factory and the copy
   answered nil, and the getters fixed values.  They need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSScrubberLayout.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSScrubberLayoutAttributes *a;
  NSScrubberLayoutAttributes *copy;

  START_SET("NSScrubberLayoutAttributes")

  a = [NSScrubberLayoutAttributes layoutAttributesForItemAtIndex: 3];
  PASS(a != nil && [a itemIndex] == 3, "the factory sets the item index");
  PASS([a alpha] == 1.0, "the alpha is 1 by default");

  [a setFrame: NSMakeRect(1, 2, 3, 4)];
  [a setAlpha: 0.5];
  copy = AUTORELEASE([a copy]);
  PASS(copy != nil && copy != a && [copy itemIndex] == 3
    && NSEqualRects([copy frame], NSMakeRect(1, 2, 3, 4))
    && [copy alpha] == 0.5, "a copy keeps the attributes");

  END_SET("NSScrubberLayoutAttributes")

  [pool release];
  return 0;
}
