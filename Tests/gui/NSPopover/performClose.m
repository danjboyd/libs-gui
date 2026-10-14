#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSPopover.h>

/* -performClose: asks the delegate whether the popover should close, and
   closes it unless the delegate refuses.  It used to forward to the
   borderless panel, which cannot perform a close, so the delegate was not
   asked and the popover stayed on screen.  Showing a popover needs a
   window, so the set is skipped when the backend is unavailable. */

@interface CloseDelegate : NSObject <NSPopoverDelegate>
{
@public
  BOOL allow;
  int asked;
}
@end

@implementation CloseDelegate
- (BOOL) popoverShouldClose: (NSPopover *)popover
{
  asked++;
  return allow;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSView *anchor;
  NSPopover *p;
  NSViewController *vc;
  CloseDelegate *d;

  START_SET("NSPopover performClose:")

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

  d = AUTORELEASE([CloseDelegate new]);
  p = AUTORELEASE([[NSPopover alloc] init]);
  vc = AUTORELEASE([[NSViewController alloc] init]);
  [vc setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 80)])];
  [p setContentViewController: vc];
  [p setDelegate: d];

  [p showRelativeToRect: [anchor bounds] ofView: anchor preferredEdge: NSMaxYEdge];
  d->allow = NO;
  [p performClose: nil];
  PASS(d->asked == 1, "performClose: asks the delegate");
  PASS([p isShown], "the popover stays shown when the delegate refuses");

  d->allow = YES;
  [p performClose: nil];
  PASS(d->asked == 2 && [p isShown] == NO,
    "the popover closes when the delegate agrees");

  [p setDelegate: nil];
  [p showRelativeToRect: [anchor bounds] ofView: anchor preferredEdge: NSMaxYEdge];
  [p performClose: nil];
  PASS([p isShown] == NO, "a popover without a delegate closes");

  END_SET("NSPopover performClose:")

  [pool release];
  return 0;
}
