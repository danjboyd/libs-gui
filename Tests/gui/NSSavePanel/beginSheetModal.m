/* -beginSheetModalForWindow:completionHandler: shows the panel as a sheet
   of the window, so the panel answers the window from -sheetParent while
   it is shown, and the handler gets the button that ended it.  The panel
   used to be run modally relative to the window, without a sheet parent.
   A timer reads the sheet parent, presses Cancel and posts an event to
   wake the modal loop.  The windows need the backend, so the set is
   skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSSavePanel.h>
#import <AppKit/NSWindow.h>

@interface PanelWatcher : NSObject
{
@public
  NSSavePanel *panel;
  NSWindow *parent;
  BOOL fired;
}
- (void) fire: (NSTimer *)timer;
@end

@implementation PanelWatcher
- (void) fire: (NSTimer *)timer
{
  fired = YES;
  parent = [panel sheetParent];
  [panel cancel: nil];
  [NSApp postEvent: [NSEvent otherEventWithType: NSApplicationDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: [panel windowNumber]
                                        context: nil
                                        subtype: 0
                                          data1: 0
                                          data2: 0]
           atStart: NO];
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  PanelWatcher *watcher;
  NSTimer *timer;
  NSWindow *w;
  NSSavePanel *panel;
  __block NSInteger result = -1;

  START_SET("NSSavePanel beginSheetModalForWindow")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 400, 300)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  panel = [NSSavePanel savePanel];

  watcher = AUTORELEASE([PanelWatcher new]);
  watcher->panel = panel;
  timer = [NSTimer timerWithTimeInterval: 0.2
                                  target: watcher
                                selector: @selector(fire:)
                                userInfo: nil
                                 repeats: NO];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSModalPanelRunLoopMode];
  [panel beginSheetModalForWindow: w
                completionHandler: ^(NSInteger code) {
      result = code;
    }];
  PASS(watcher->fired && watcher->parent == w,
    "the panel is a sheet of the window while it is shown");
  PASS(result == NSCancelButton, "the handler gets the button pressed");
  PASS([panel sheetParent] == nil && [w attachedSheet] == nil,
    "the sheet is detached once it has ended");

  END_SET("NSSavePanel beginSheetModalForWindow")

  [pool release];
  return 0;
}
