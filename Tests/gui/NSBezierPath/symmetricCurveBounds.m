/* The bounds of a curve include its extremes when the derivative of the
   curve is linear, as for a curve whose control points are symmetric.  The
   extremes were found by dividing by the quadratic coefficient of the
   derivative, so in that case none was found and the bounds missed the
   curve's bulge.  A path is a plain model object and needs no backend. */
#include "Testing.h"

#include <math.h>
#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSBezierPath.h>

#define NEAR(a, b) (fabs((double)(a) - (double)(b)) < 0.0001)

int main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSBezierPath *path;
  NSRect bounds;

  START_SET("NSBezierPath bounds of a symmetric curve")

  path = [NSBezierPath bezierPath];
  [path moveToPoint: NSMakePoint(0, 0)];
  [path curveToPoint: NSMakePoint(10, 0)
       controlPoint1: NSMakePoint(0, 10)
       controlPoint2: NSMakePoint(10, 10)];
  bounds = [path bounds];
  PASS(NEAR(NSMinX(bounds), 0) && NEAR(NSMaxX(bounds), 10),
    "the bounds span the curve horizontally");
  PASS(NEAR(NSMinY(bounds), 0) && NEAR(NSMaxY(bounds), 7.5),
    "the bounds include the top of the curve");
  PASS(NEAR(NSMaxY([path controlPointBounds]), 10),
    "the control point bounds include the control points");

  END_SET("NSBezierPath bounds of a symmetric curve")

  [pool release];
  return 0;
}
