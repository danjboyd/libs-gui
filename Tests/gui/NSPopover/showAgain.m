#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSPopover.h>

/* A popover can be shown again after it was closed.  Its panel is released
   when it is closed, but the popover kept the pointer to it, and so
   messaged a freed panel when it was shown again.  Showing a popover needs
   a window, so the set is skipped when the backend is unavailable. */

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSView *anchor;
  NSPopover *p;
  NSViewController *vc;

  START_SET("NSPopover show again")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 200, 200)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  anchor = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(10, 10, 20, 20)]);
  [[window contentView] addSubview: anchor];

  p = AUTORELEASE([[NSPopover alloc] init]);
  vc = AUTORELEASE([[NSViewController alloc] init]);
  [vc setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 80)])];
  [p setContentViewController: vc];

  [p showRelativeToRect: [anchor bounds] ofView: anchor preferredEdge: NSMaxYEdge];
  PASS([p isShown], "the popover is shown");
  [p close];
  PASS([p isShown] == NO, "the popover is closed");

  PASS_RUNS([p showRelativeToRect: [anchor bounds]
                           ofView: anchor
                    preferredEdge: NSMaxYEdge],
    "the popover can be shown again after it was closed");
  PASS([p isShown], "the popover is shown again");
  [p close];

  END_SET("NSPopover show again")

  [pool release];
  return 0;
}
