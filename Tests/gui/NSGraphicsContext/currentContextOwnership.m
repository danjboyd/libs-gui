/* The current thread retains its current graphics context, as it releases
   the context when it is deallocated.  +setCurrentContext: used not to
   retain the context with the non-fragile ABI, so a context released by its
   creator after being made current was left dangling, and was released
   again when the thread went away.
   Creating a context needs the backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSBitmapImageRep.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSGraphicsContext.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSBitmapImageRep *rep;
  NSGraphicsContext *saved;
  NSGraphicsContext *context;
  NSUInteger count;

  START_SET("NSGraphicsContext current context ownership")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  rep = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
		  pixelsWide: 4
		  pixelsHigh: 4
	       bitsPerSample: 8
	     samplesPerPixel: 4
		    hasAlpha: YES
		    isPlanar: NO
	      colorSpaceName: NSDeviceRGBColorSpace
		 bytesPerRow: 0
		bitsPerPixel: 0]);
  context = [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
  saved = RETAIN([NSGraphicsContext currentContext]);
  count = [context retainCount];

  [NSGraphicsContext setCurrentContext: context];
  PASS([NSGraphicsContext currentContext] == context,
    "the context is current");
  PASS([context retainCount] == count + 1,
    "the thread retains its current context");

  [NSGraphicsContext setCurrentContext: saved];
  PASS([context retainCount] == count,
    "the thread releases a context that is no longer current");
  RELEASE(saved);

  END_SET("NSGraphicsContext current context ownership")

  [pool release];
  return 0;
}
