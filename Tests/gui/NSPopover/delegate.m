#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSNotification.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSPopover.h>

/* Showing and closing a popover posts the will and did show and close
   notifications and sends them to its delegate.  The show notifications
   were never posted, the did-close notification was posted from a window
   delegate method that is never sent, and the delegate was never told.
   Showing a popover needs a window, so the set is skipped when the backend
   is unavailable. */

@interface PopoverDelegate : NSObject <NSPopoverDelegate>
{
@public
  NSMutableArray *calls;
}
@end

@implementation PopoverDelegate
- (id) init
{
  if ((self = [super init]) != nil)
    {
      calls = [NSMutableArray new];
    }
  return self;
}
- (void) dealloc
{
  RELEASE(calls);
  [super dealloc];
}
- (void) popoverWillShow: (NSNotification *)n
{
  [calls addObject: @"willShow"];
}
- (void) popoverDidShow: (NSNotification *)n
{
  [calls addObject: @"didShow"];
}
- (void) popoverWillClose: (NSNotification *)n
{
  [calls addObject: @"willClose"];
}
- (void) popoverDidClose: (NSNotification *)n
{
  [calls addObject: @"didClose"];
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
  PopoverDelegate *d;
  NSArray *expected;

  START_SET("NSPopover delegate")

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

  d = AUTORELEASE([PopoverDelegate new]);
  p = AUTORELEASE([[NSPopover alloc] init]);
  vc = AUTORELEASE([[NSViewController alloc] init]);
  [vc setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 80)])];
  [p setContentViewController: vc];
  [p setDelegate: d];

  [p showRelativeToRect: [anchor bounds] ofView: anchor preferredEdge: NSMaxYEdge];
  expected = [NSArray arrayWithObjects: @"willShow", @"didShow", nil];
  PASS_EQUAL(d->calls, expected, "showing tells the delegate");

  [p close];
  expected = [NSArray arrayWithObjects: @"willShow", @"didShow",
    @"willClose", @"didClose", nil];
  PASS_EQUAL(d->calls, expected, "closing tells the delegate");

  [p close];
  PASS([d->calls count] == 4, "closing a closed popover tells nobody");

  [p setDelegate: nil];

  END_SET("NSPopover delegate")

  [pool release];
  return 0;
}
