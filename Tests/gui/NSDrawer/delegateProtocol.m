#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSDrawer.h>

/* NSDrawerDelegate is a protocol whose methods are optional, as in AppKit,
   so a delegate can adopt it implementing only the methods it needs.  It
   used to be declared as a root class, which nothing could adopt.  This
   only uses the protocol, so it needs no backend. */

@interface Delegate : NSObject <NSDrawerDelegate>
@end

@implementation Delegate
- (BOOL) drawerShouldOpen: (NSDrawer *)sender
{
  return NO;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  Delegate *d;

  START_SET("NSDrawerDelegate protocol")

  d = AUTORELEASE([Delegate new]);
  PASS(@protocol(NSDrawerDelegate) != nil,
    "NSDrawerDelegate is a protocol");
  PASS([d conformsToProtocol: @protocol(NSDrawerDelegate)],
    "a delegate can adopt NSDrawerDelegate");
  PASS([d drawerShouldOpen: nil] == NO
    && [d respondsToSelector: @selector(drawerShouldClose:)] == NO,
    "a delegate need only implement the methods it needs");

  END_SET("NSDrawerDelegate protocol")

  [pool release];
  return 0;
}
