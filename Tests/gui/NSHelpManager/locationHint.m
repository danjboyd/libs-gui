/* -showContextHelpForObject:locationHint: shows the help panel at the hint,
 * or centred on the screen for the zero point, which NSHelpPanel passes.
 * The panel used to be centred on the screen for every hint.  The panel is run
 * modally, so a timer records where it is and aborts the modal loop.  It
 * needs the backend, so the set is skipped without it.
 */
#include "Testing.h"
#include <Foundation/Foundation.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSHelpManager.h>
#include <AppKit/NSScreen.h>
#include <AppKit/NSWindow.h>

@interface ModalWatcher : NSObject
{
@public
  NSRect frame;
  BOOL fired;
}
- (void) fire: (NSTimer *)timer;
@end

@implementation ModalWatcher
- (void) fire: (NSTimer *)timer
{
  fired = YES;
  frame = [[NSApp modalWindow] frame];
  [NSApp abortModal];
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSHelpManager *hm;
  ModalWatcher *watcher;
  NSTimer *timer;
  id object;
  NSPoint hint = NSMakePoint(200, 300);
  BOOL shown;

  START_SET("context help location hint")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  hm = [NSHelpManager sharedHelpManager];
  object = AUTORELEASE([NSObject new]);
  [hm setContextHelp: AUTORELEASE([[NSAttributedString alloc]
    initWithString: @"Help text"]) forObject: object];

  watcher = AUTORELEASE([ModalWatcher new]);
  timer = [NSTimer timerWithTimeInterval: 0.1
                                  target: watcher
                                selector: @selector(fire:)
                                userInfo: nil
                                 repeats: NO];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSModalPanelRunLoopMode];

  shown = [hm showContextHelpForObject: object locationHint: hint];
  PASS(shown, "context help is shown for an object with help");
  PASS(watcher->fired && NSPointInRect(hint, watcher->frame),
    "the help panel is shown at the location hint");

  watcher->fired = NO;
  timer = [NSTimer timerWithTimeInterval: 0.1
                                  target: watcher
                                selector: @selector(fire:)
                                userInfo: nil
                                 repeats: NO];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSModalPanelRunLoopMode];
  [hm showContextHelpForObject: object locationHint: NSZeroPoint];
  {
    NSRect screen = [[NSScreen mainScreen] frame];

    PASS(watcher->fired && NSPointInRect(
      NSMakePoint(NSMidX(screen), NSMidY(screen)), watcher->frame),
      "without a hint the help panel is centred on the screen");
  }

  [hm removeContextHelpForObject: object];

  END_SET("context help location hint")

  [pool release];
  return 0;
}
