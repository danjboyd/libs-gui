/* Slider accessories and their behaviours can be made, and a behaviour
   made with a target and action, or with a handler, calls it from
   -handleAction:.  Accessories keep their state in keyed archives.  Every
   factory answered nil.  Accessories are model objects here and need no
   backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSKeyedArchiver.h>
#include <AppKit/NSSliderAccessory.h>

@interface AccessoryTarget : NSObject
{
@public
  id sender;
  int calls;
}
- (void) act: (id)s;
@end

@implementation AccessoryTarget
- (void) act: (id)s
{
  sender = s;
  calls++;
}
@end

#if __has_feature(blocks)
static NSSliderAccessoryBehavior *
handlerBehavior(int *counter)
{
  int step = 3;

  /* A block capturing a local variable starts out on the stack. */
  return [NSSliderAccessoryBehavior behaviorWithHandler:
    ^(NSSliderAccessory *a) { *counter += step; }];
}
#endif

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSliderAccessory *a;
  NSSliderAccessory *c;
  NSSliderAccessoryBehavior *b;
  AccessoryTarget *t = AUTORELEASE([AccessoryTarget new]);

  START_SET("NSSliderAccessory behaviours")

  a = [NSSliderAccessory accessoryWithImage: nil];
  PASS(a != nil, "an accessory is made");
  PASS([a isEnabled], "an accessory is enabled");
  PASS([a behavior] != nil, "an accessory has the automatic behaviour");

  PASS([NSSliderAccessoryBehavior automaticBehavior] != nil
    && [NSSliderAccessoryBehavior valueResetBehavior] != nil
    && [NSSliderAccessoryBehavior valueStepBehavior] != nil,
    "the standard behaviours are made");

  b = [NSSliderAccessoryBehavior behaviorWithTarget: t
                                             action: @selector(act:)];
  [a setBehavior: b];
  [[a behavior] handleAction: a];
  PASS(t->calls == 1 && t->sender == a,
    "a target and action behaviour sends the action with the accessory");

  c = AUTORELEASE([a copy]);
  PASS(c != a && [c behavior] == b && [c isEnabled],
    "a copy has the behaviour and state");

  [a setEnabled: NO];
  c = [NSKeyedUnarchiver unarchiveObjectWithData:
    [NSKeyedArchiver archivedDataWithRootObject: a]];
  PASS(c != nil && [c isEnabled] == NO && [c behavior] != nil,
    "an accessory keeps its state and behaviour in a keyed archive");

#if __has_feature(blocks)
  {
    int counter = 0;

    b = handlerBehavior(&counter);
    [b handleAction: a];
    PASS(counter == 3, "a handler behaviour calls its copied handler");
  }
#endif

  END_SET("NSSliderAccessory behaviours")

  [pool release];
  return 0;
}
