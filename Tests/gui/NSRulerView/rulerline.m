#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSRulerView.h>
#import <AppKit/NSWindow.h>

/* -moveRulerlineFromLocation:toLocation: draws a line across the ruler at
   the new location and erases the one at the old location, drawing nothing
   for a negative location.  It used to do nothing.  The pixels are not
   read back here; this checks that drawing and erasing the line work in a
   window and are skipped without one.  Needs a window server, so it skips
   cleanly without one. */

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSScrollView *sv;
  NSRulerView *ruler;
  NSRulerView *detached;

  START_SET("NSRulerView rulerline")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 300, 200)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  sv = AUTORELEASE([[NSScrollView alloc]
    initWithFrame: NSMakeRect(0, 0, 300, 200)]);
  [sv setDocumentView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 600, 400)])];
  [sv setHasHorizontalRuler: YES];
  [sv setRulersVisible: YES];
  [[window contentView] addSubview: sv];
  [window orderFront: nil];
  ruler = [sv horizontalRulerView];

  PASS_RUNS([ruler moveRulerlineFromLocation: -1.0 toLocation: 60.0],
    "a ruler line is drawn");
  PASS_RUNS([ruler moveRulerlineFromLocation: 60.0 toLocation: 80.0],
    "a ruler line is moved");
  PASS_RUNS([ruler moveRulerlineFromLocation: 80.0 toLocation: -1.0],
    "a ruler line is erased");

  detached = AUTORELEASE([[NSRulerView alloc] initWithScrollView: nil
    orientation: NSHorizontalRuler]);
  PASS_RUNS([detached moveRulerlineFromLocation: -1.0 toLocation: 10.0],
    "a ruler outside a window draws no line");

  [window orderOut: nil];

  END_SET("NSRulerView rulerline")

  [pool release];
  return 0;
}
