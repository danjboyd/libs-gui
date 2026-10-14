/* NSWindowListForContext lists the application's window numbers, as
 * NSWindowList does, into the array it is given, writing only as many
 * entries as there are windows.  It used to do nothing.  Windows need the
 * backend, so the set skips without it.
 */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSInteger expected[8] = { 0 };
  NSInteger list[9];
  NSInteger count = 0;
  NSInteger i;
  BOOL same = YES;

  START_SET("NSWindowListForContext")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 100, 100)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  [window orderFront: nil];

  NSCountWindows(&count);
  if (count > 8)
    count = 8;
  NSWindowList(count, expected);

  for (i = 0; i < 9; i++)
    list[i] = -1;
  NSWindowListForContext(0, count, list);
  for (i = 0; i < count; i++)
    {
      if (list[i] != expected[i])
	same = NO;
    }
  PASS(count >= 1 && same, "the window numbers are those of NSWindowList");
  PASS(list[count] == -1, "no more entries than asked for are written");

  [window orderOut: nil];

  END_SET("NSWindowListForContext")

  [pool release];
  return 0;
}
