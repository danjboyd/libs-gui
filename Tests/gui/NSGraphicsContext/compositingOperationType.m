/* NSCompositingOperation is an NS_ENUM type, as in Cocoa, so Swift can
   import it as an enumeration (.sourceOver, .copy, ...).  It was an
   NSUInteger typedef beside an enumeration with another name.  The
   constants keep their values and the type keeps its size and type
   encoding.  Needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSGraphicsContext.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool		*arp = [NSAutoreleasePool new];
  NSCompositingOperation	op = NSCompositeSourceOver;

  START_SET("NSCompositingOperation")

  PASS(sizeof(NSCompositingOperation) == sizeof(NSUInteger)
    && strcmp(@encode(NSCompositingOperation), @encode(NSUInteger)) == 0,
    "NSCompositingOperation has the size and encoding of NSUInteger");
  PASS(NSCompositeClear == 0
    && NSCompositeCopy == 1
    && NSCompositeSourceOver == 2
    && NSCompositeSourceIn == 3
    && NSCompositeSourceOut == 4
    && NSCompositeSourceAtop == 5
    && NSCompositeDestinationOver == 6
    && NSCompositeDestinationIn == 7
    && NSCompositeDestinationOut == 8
    && NSCompositeDestinationAtop == 9
    && NSCompositeXOR == 10
    && NSCompositePlusDarker == 11
    && NSCompositeHighlight == 12
    && NSCompositePlusLighter == 13,
    "the compositing operations have Cocoa's values");
  PASS(op == 2, "a compositing operation holds its constant");

  END_SET("NSCompositingOperation")

  [arp release];
  return 0;
}
