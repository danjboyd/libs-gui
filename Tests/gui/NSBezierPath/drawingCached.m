/* A path that caches itself draws like any other path, and draws again in
 * a new colour.  The cached image used to be drawn with the context current
 * before the image was focused, so it stayed transparent, and a cached path
 * filled nothing; a colour change would not have shown either.
 *
 * None of it is particular to one backend, so it runs against whichever one
 * is installed and skips when there is none.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"
#import "../GSDrawTest.h"

#import <AppKit/AppKit.h>
#import <AppKit/NSBezierPath.h>

int
main(int argc, const char **argv)
{
  START_SET("cached path drawing")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  if (NO == GSCanDrawOffscreen())
    {
      SKIP("the installed backend does not draw offscreen")
    }

  int w = 20, h = 20;
  NSImage *img;
  NSBitmapImageRep *rep;
  NSBezierPath *p;

  p = [NSBezierPath bezierPathWithRect: NSMakeRect(5, 5, 10, 10)];
  [p setCachesBezierPath: YES];
  PASS([p cachesBezierPath], "the path caches itself");

  img = GSDrawBegin(w, h);
  [[NSColor whiteColor] set];
  NSRectFill(NSMakeRect(0, 0, w, h));
  [[NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 1.0 alpha: 1.0] set];
  [p fill];
  rep = GSDrawEnd(img, w, h);
  PASS(rep != nil && GSPixelIs(rep, 10, h - 1 - 10, 0, 0, 255),
       "a cached path is filled");
  PASS(rep != nil && GSPixelIs(rep, 2, h - 1 - 2, 255, 255, 255),
       "a cached path fills only its inside");

  img = GSDrawBegin(w, h);
  [[NSColor whiteColor] set];
  NSRectFill(NSMakeRect(0, 0, w, h));
  [[NSColor colorWithDeviceRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0] set];
  [p fill];
  rep = GSDrawEnd(img, w, h);
  PASS(rep != nil && GSPixelIs(rep, 10, h - 1 - 10, 255, 0, 0),
       "a cached path is filled in the current colour");

  END_SET("cached path drawing")
  return 0;
}
