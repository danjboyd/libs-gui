/* An NSGradient archives its colours and their locations, with keyed and
 * non-keyed coding.  Both coding methods used to be empty, so a decoded
 * gradient had no colour stops.
 */
#include "Testing.h"
#include <math.h>
#include <Foundation/NSArchiver.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSKeyedArchiver.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSColorSpace.h>
#include <AppKit/NSGradient.h>

#define NEAR(a, b) (fabs((double)(a) - (double)(b)) < 0.0001)

static BOOL
sameStops(NSGradient *a, NSGradient *b)
{
  NSInteger i;

  if (b == nil || [a numberOfColorStops] != [b numberOfColorStops])
    {
      return NO;
    }
  for (i = 0; i < [a numberOfColorStops]; i++)
    {
      NSColor	*ca;
      NSColor	*cb;
      CGFloat	la;
      CGFloat	lb;

      [a getColor: &ca location: &la atIndex: i];
      [b getColor: &cb location: &lb atIndex: i];
      if (![ca isEqual: cb] || !NEAR(la, lb))
        {
          return NO;
        }
    }
  return YES;
}

int main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  CGFloat		locations[3] = { 0.0, 0.25, 1.0 };
  NSArray		*colors;
  NSGradient		*g;
  NSGradient		*d;

  START_SET("NSGradient coding")
    colors = [NSArray arrayWithObjects:
      [NSColor colorWithCalibratedRed: 1 green: 0 blue: 0 alpha: 1],
      [NSColor colorWithCalibratedRed: 0 green: 1 blue: 0 alpha: 1],
      [NSColor colorWithCalibratedRed: 0 green: 0 blue: 1 alpha: 1],
      nil];
    g = AUTORELEASE([[NSGradient alloc] initWithColors: colors
                                           atLocations: locations
                                            colorSpace: nil]);

    d = [NSKeyedUnarchiver unarchiveObjectWithData:
      [NSKeyedArchiver archivedDataWithRootObject: g]];
    PASS(sameStops(g, d),
      "keyed coding keeps the colours and their locations");
    PASS([[d colorSpace] colorSpaceModel] == [[g colorSpace] colorSpaceModel],
      "keyed coding gives the colour space of the colours");

    d = [NSUnarchiver unarchiveObjectWithData:
      [NSArchiver archivedDataWithRootObject: g]];
    PASS(sameStops(g, d),
      "non-keyed coding keeps the colours and their locations");
  END_SET("NSGradient coding")

  [pool release];
  return 0;
}
