/* A sheet answers the window it is attached to from -sheetParent while it
   is shown, and nil once it has ended; a plain child window has no sheet
   parent.  -sheetParent always answered nil.  The sheet is run modally,
   so a timer reads the sheet parent, ends the sheet and posts an event
   to wake the modal loop.  The windows need the backend, so the set is
   skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSWindow.h>

@interface SheetWatcher : NSObject
{
@public
  NSWindow *sheet;
  NSWindow *parent;
  BOOL fired;
}
- (void) fire: (NSTimer *)timer;
@end

@implementation SheetWatcher
- (void) fire: (NSTimer *)timer
{
  fired = YES;
  parent = [sheet sheetParent];
  [NSApp endSheet: sheet];
  /* Ending the sheet only marks the modal session as stopped; the modal
     loop waits for an event, so post one to wake it. */
  [NSApp postEvent: [NSEvent otherEventWithType: NSApplicationDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: [sheet windowNumber]
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
  SheetWatcher *watcher;
  NSTimer *timer;
  NSWindow *w;
  NSWindow *sheet;
  NSWindow *child;

  START_SET("NSWindow sheetParent")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 200, 200)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  sheet = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 100, 100)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  [sheet setReleasedWhenClosed: NO];
  child = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 100, 100)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);

  PASS([sheet sheetParent] == nil, "a window not shown as a sheet has none");

  [child setParentWindow: w];
  PASS([child sheetParent] == nil, "a child window has no sheet parent");
  [child setParentWindow: nil];

  watcher = AUTORELEASE([SheetWatcher new]);
  watcher->sheet = sheet;
  timer = [NSTimer timerWithTimeInterval: 0.1
                                  target: watcher
                                selector: @selector(fire:)
                                userInfo: nil
                                 repeats: NO];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSModalPanelRunLoopMode];
  [NSApp beginSheet: sheet
     modalForWindow: w
      modalDelegate: nil
     didEndSelector: NULL
        contextInfo: NULL];
  PASS(watcher->fired && watcher->parent == w,
    "a sheet answers its window while it is shown");
  PASS([sheet sheetParent] == nil, "and none once it has ended");

  END_SET("NSWindow sheetParent")

  [pool release];
  return 0;
}
