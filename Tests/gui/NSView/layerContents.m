/* A view keeps its layer contents placement and redraw policy, which
   default to scaling the axes independently and never redrawing, and
   ignores values outside their enumerations.  The setters were stubs that
   only logged.  Views need no backend for this. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSView *v;

  START_SET("NSView layer contents placement and redraw policy")

  v = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);
  PASS([v layerContentsPlacement]
    == NSViewLayerContentsPlacementScaleAxesIndependently,
    "the placement scales the axes independently by default");
  PASS([v layerContentsRedrawPolicy] == NSViewLayerContentsRedrawNever,
    "the redraw policy is never by default");

  [v setLayerContentsPlacement: NSViewLayerContentsPlacementTopLeft];
  [v setLayerContentsRedrawPolicy: NSViewLayerContentsRedrawCrossfade];
  PASS([v layerContentsPlacement] == NSViewLayerContentsPlacementTopLeft,
    "the placement is kept");
  PASS([v layerContentsRedrawPolicy] == NSViewLayerContentsRedrawCrossfade,
    "the redraw policy is kept");

  [v setLayerContentsPlacement: 99];
  [v setLayerContentsRedrawPolicy: 99];
  PASS([v layerContentsPlacement] == NSViewLayerContentsPlacementTopLeft
    && [v layerContentsRedrawPolicy] == NSViewLayerContentsRedrawCrossfade,
    "values outside the enumerations are ignored");

  END_SET("NSView layer contents placement and redraw policy")

  [pool release];
  return 0;
}
