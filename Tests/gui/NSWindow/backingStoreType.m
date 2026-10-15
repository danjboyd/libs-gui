/* NSBackingStoreType is an NS_ENUM type, as in Cocoa, so Swift can import
   it as an enumeration (NSWindow.BackingStoreType).  It was an NSUInteger
   typedef beside an enumeration with another name.  The constants keep
   their values and the type keeps its size and type encoding. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSGraphicsContext.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSBackingStoreType	backing = NSBackingStoreBuffered;

  START_SET("NSBackingStoreType")

  PASS(sizeof(NSBackingStoreType) == sizeof(NSUInteger)
    && strcmp(@encode(NSBackingStoreType), @encode(NSUInteger)) == 0,
    "NSBackingStoreType has the size and encoding of NSUInteger");
  PASS(NSBackingStoreRetained == 0
    && NSBackingStoreNonretained == 1
    && NSBackingStoreBuffered == 2,
    "the backing store types have Cocoa's values");
  PASS(backing == 2, "a backing store type holds its constant");

  END_SET("NSBackingStoreType")

  [arp release];
  return 0;
}
