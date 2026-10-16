/* NSDragOperation is an NS_OPTIONS type, as in Cocoa, so Swift can import
   it as an option set (.copy, .move, ...).  It was an NSUInteger typedef
   beside an enumeration with another name.  The operations keep their
   values, the type keeps its size and type encoding, and operations
   still combine and mask.  Needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSDragging.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSDragOperation	mask;

  START_SET("NSDragOperation")

  PASS(sizeof(NSDragOperation) == sizeof(NSUInteger)
    && strcmp(@encode(NSDragOperation), @encode(NSUInteger)) == 0,
    "NSDragOperation has the size and encoding of NSUInteger");
  PASS(NSDragOperationNone == 0
    && NSDragOperationCopy == 1
    && NSDragOperationLink == 2
    && NSDragOperationGeneric == 4
    && NSDragOperationPrivate == 8
    && NSDragOperationAll == 15
    && NSDragOperationMove == 16
    && NSDragOperationDelete == 32,
    "the drag operations have Cocoa's values");
  PASS(NSDragOperationEvery == UINT_MAX,
    "NSDragOperationEvery keeps its value");

  mask = NSDragOperationCopy | NSDragOperationMove;
  PASS((mask & NSDragOperationEvery) == mask
    && (mask & NSDragOperationLink) == NSDragOperationNone,
    "drag operations combine and mask");

  END_SET("NSDragOperation")

  [arp release];
  return 0;
}
