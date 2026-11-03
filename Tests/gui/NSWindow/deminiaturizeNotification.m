/* -[NSWindow deminiaturize:] posts NSWindowDidDeminiaturizeNotification
   once the window is shown again, as it does when the window manager
   deminiaturizes the window.  It used to clear the miniaturized flag
   before the method that posts tested it, so nothing was posted.  The
   window needs the backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSNotification.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSWindow.h>

@interface Observer : NSObject
{
@public
  int deminiaturized;
  BOOL miniaturizedWhenPosted;
}
@end
@implementation Observer
- (void) didDeminiaturize: (NSNotification *)n
{
  deminiaturized++;
  miniaturizedWhenPosted = [[n object] isMiniaturized];
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  Observer *observer;

  START_SET("NSWindow deminiaturize notification")

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

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 200, 100)
	      styleMask: NSTitledWindowMask | NSMiniaturizableWindowMask
		backing: NSBackingStoreBuffered
		  defer: NO]);
  [window setReleasedWhenClosed: NO];
  observer = AUTORELEASE([Observer new]);
  [[NSNotificationCenter defaultCenter]
    addObserver: observer
       selector: @selector(didDeminiaturize:)
	   name: NSWindowDidDeminiaturizeNotification
	 object: window];
  [window orderFront: nil];
  [window miniaturize: nil];
  PASS([window isMiniaturized], "the window is miniaturized");

  [window deminiaturize: nil];
  PASS(![window isMiniaturized], "-deminiaturize: deminiaturizes the window");
  PASS(observer->deminiaturized == 1,
    "-deminiaturize: posts NSWindowDidDeminiaturizeNotification");
  PASS(!observer->miniaturizedWhenPosted,
    "the window is no longer miniaturized when it is posted");
  [window deminiaturize: nil];
  PASS(observer->deminiaturized == 1,
    "a window that is not miniaturized posts nothing");

  [[NSNotificationCenter defaultCenter] removeObserver: observer];
  END_SET("NSWindow deminiaturize notification")

  [pool release];
  return 0;
}
