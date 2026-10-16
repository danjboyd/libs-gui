/* NSGetWindowServerMemory answers 0 and reports the memory the
   application's windows use, at least the backing store of a shown
   buffered window, and describes the windows.  It used to answer -1 and
   report nothing.  Windows need the backend, so the set skips without
   it.
 */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  int virtualMemory = -1;
  int backingMemory = -1;
  NSString *dump = nil;
  int result;

  START_SET("NSGetWindowServerMemory")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 100, 50)
              styleMask: NSBorderlessWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  [window orderFront: nil];

  result = NSGetWindowServerMemory(0, &virtualMemory, &backingMemory, &dump);
  PASS(result == 0, "NSGetWindowServerMemory answers 0");
  PASS(backingMemory >= 100 * 50 * 4,
    "the backing store of a shown window is counted");
  PASS(virtualMemory >= backingMemory, "the virtual memory is reported");
  PASS([dump length] > 0, "the windows are described");
  PASS(NSGetWindowServerMemory(0, NULL, NULL, NULL) == 0,
    "the results may be left out");

  [window orderOut: nil];

  END_SET("NSGetWindowServerMemory")

  [pool release];
  return 0;
}
