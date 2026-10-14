/* A status item keeps its alternate image and double action, and
   -sendActionOn: answers the previous mask, starting from the left mouse
   up mask.  These were stubs answering nil, NULL and 0.  A status bar made
   with -init needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSEvent.h>
#include <AppKit/NSImage.h>
#include <AppKit/NSStatusBar.h>
#include <AppKit/NSStatusItem.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSStatusBar *bar;
  NSStatusItem *item;
  NSImage *image;

  START_SET("NSStatusItem state")

  bar = AUTORELEASE([[NSStatusBar alloc] init]);
  item = [bar statusItemWithLength: NSVariableStatusItemLength];

  image = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(8, 8)]);
  [item setAlternateImage: image];
  PASS([item alternateImage] == image, "the alternate image is kept");

  [item setDoubleAction: @selector(description)];
  PASS(sel_isEqual([item doubleAction], @selector(description)),
    "the double action is kept");

  PASS([item sendActionOn: NSLeftMouseDownMask] == NSLeftMouseUpMask,
    "the action is sent on left mouse up by default");
  PASS([item sendActionOn: NSLeftMouseUpMask] == NSLeftMouseDownMask,
    "sendActionOn: answers the previous mask");

  END_SET("NSStatusItem state")

  [pool release];
  return 0;
}
