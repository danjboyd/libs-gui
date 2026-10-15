/* A transition layout keeps the values given for its animated keys, and
   answers 0 for a key never given one.  -updateValue:forAnimatedKey: was
   a stub, and -valueForAnimatedKey: always answered 1.  Layouts need no
   backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSCollectionViewFlowLayout.h>
#include <AppKit/NSCollectionViewTransitionLayout.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionViewTransitionLayout *t;

  START_SET("NSCollectionViewTransitionLayout animated keys")

  t = AUTORELEASE([[NSCollectionViewTransitionLayout alloc]
    initWithCurrentLayout: AUTORELEASE([NSCollectionViewFlowLayout new])
               nextLayout: AUTORELEASE([NSCollectionViewFlowLayout new])]);
  PASS([t valueForAnimatedKey: @"scale"] == 0.0,
    "a key never given a value answers 0");
  [t updateValue: 0.25 forAnimatedKey: @"scale"];
  [t updateValue: 3.0 forAnimatedKey: @"angle"];
  PASS([t valueForAnimatedKey: @"scale"] == 0.25
    && [t valueForAnimatedKey: @"angle"] == 3.0,
    "each key keeps its value");
  [t updateValue: 0.75 forAnimatedKey: @"scale"];
  PASS([t valueForAnimatedKey: @"scale"] == 0.75, "a value can be updated");

  END_SET("NSCollectionViewTransitionLayout animated keys")

  [pool release];
  return 0;
}
