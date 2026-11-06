/* In NSWindows95InterfaceStyle, a transient menu (a context menu) ignores
 * the first release of the mouse while the pointer stays on the item its
 * tracking began on: the release of the press that opened the menu must not
 * carry out an item.  Its submenus are transient too, but the pointer
 * reaches them by moving into them; there is no such press, and the first
 * release there is a click on the item, which must be carried out at once.
 * When it was ignored as well, the item the submenu was entered by (the
 * first item, level with its parent) needed a second click.
 */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDate.h>
#include <Foundation/NSRunLoop.h>
#include <Foundation/NSString.h>
#include <Foundation/NSTimer.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSMenuItem.h>
#include <AppKit/NSMenuView.h>
#include <AppKit/NSWindow.h>
#include <GNUstepGUI/GSDisplayServer.h>
#include <signal.h>
#include <unistd.h>

static NSString *performed = nil;
static int releasesPosted = 0;
static int releasesAtEnd = 0;

@interface Recorder : NSObject
- (void) hit: (id)sender;
- (void) tick: (NSTimer *)timer;
@end

@implementation Recorder

- (void) hit: (id)sender
{
  ASSIGN(performed, [(NSMenuItem *)sender title]);
}

/* Tracking reads the pointer where it is, and turns of the run loop let it
 * do so between the releases: one release, then a second if tracking is
 * still going on. */
- (void) tick: (NSTimer *)timer
{
  if (releasesPosted < 2)
    {
      NSEvent *up = [NSEvent mouseEventWithType: NSLeftMouseUp
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: 0
                                        context: nil
                                    eventNumber: 0
                                     clickCount: 1
                                       pressure: 0];

      releasesPosted++;
      [NSApp postEvent: up atStart: NO];
    }
}

@end

static void
timedOut(int sig)
{
  printf("Failed test:     transientSubmenuRelease.m:0 ... menu tracking did not end\n");
  fflush(stdout);
  _exit(1);
}

/* Presses the mouse in a menu view with the pointer at a point, and lets
 * the releases come.  Returns how many releases it took to end tracking. */
static int
clickIn(NSMenuView *view, NSPoint point)
{
  NSEvent *down;
  NSTimer *timer;

  DESTROY(performed);
  releasesPosted = 0;
  [GSCurrentServer() setMouseLocation: point onScreen: 0];
  down = [NSEvent mouseEventWithType: NSLeftMouseDown
                            location: NSZeroPoint
                       modifierFlags: 0
                           timestamp: 0
                        windowNumber: [[view window] windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 0];
  timer = [NSTimer timerWithTimeInterval: 0.3
                                  target: AUTORELEASE([Recorder new])
                                selector: @selector(tick:)
                                userInfo: nil
                                 repeats: YES];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSEventTrackingRunLoopMode];
  signal(SIGALRM, timedOut);
  alarm(20);
  [view mouseDown: down];
  alarm(0);
  releasesAtEnd = releasesPosted;
  [timer invalidate];
  /* A release still queued belongs to no menu: drop it. */
  [NSApp nextEventMatchingMask: NSLeftMouseUpMask
                     untilDate: [NSDate dateWithTimeIntervalSinceNow: 0.5]
                        inMode: NSDefaultRunLoopMode
                       dequeue: YES];
  return releasesAtEnd;
}

static NSPoint
centerOfItem(NSMenuView *view, NSInteger index)
{
  NSRect r = [view rectOfItemAtIndex: index];

  return [[view window] convertBaseToScreen:
    [view convertPoint: NSMakePoint(NSMidX(r), NSMidY(r)) toView: nil]];
}

static NSInteger
itemUnderPointer(NSMenuView *view)
{
  NSPoint location = [[view window] mouseLocationOutsideOfEventStream];

  return [view indexOfItemAtPoint: [view convertPoint: location
                                            fromView: nil]];
}

/* The context menu on screen, its Share submenu attached and open. */
static void
openMenu(NSMenu *menu, NSMenuView *view)
{
  [menu displayTransient];
  [[[menu menuRepresentation] window] setFrameOrigin: NSMakePoint(300, 400)];
  [view setHighlightedItemIndex: 1];
  [view attachSubmenuForItemAtIndex: 1];
}

static void
closeMenu(NSMenu *menu, NSMenuView *view)
{
  [view detachSubmenu];
  [view setHighlightedItemIndex: -1];
  if ([menu isTransient])
    {
      [menu closeTransient];
    }
}

int
main(int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);

  START_SET("NSMenuView release in a transient submenu")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name]
            isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  Recorder *recorder = AUTORELEASE([Recorder new]);
  NSMenu *share = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Share"]);
  NSMenu *menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Context"]);
  NSMenuView *view;
  NSMenuView *shareView;
  NSMenuItem *item;
  int releases;

  [[share addItemWithTitle: @"Email" action: @selector(hit:)
             keyEquivalent: @""] setTarget: recorder];
  [[share addItemWithTitle: @"Link" action: @selector(hit:)
             keyEquivalent: @""] setTarget: recorder];
  [[menu addItemWithTitle: @"Copy" action: @selector(hit:)
            keyEquivalent: @""] setTarget: recorder];
  item = (NSMenuItem *)[menu addItemWithTitle: @"Share" action: NULL
                                keyEquivalent: @""];
  [menu setSubmenu: share forItem: item];
  [menu setAutoenablesItems: NO];
  [share setAutoenablesItems: NO];

  view = (NSMenuView *)[menu menuRepresentation];
  shareView = (NSMenuView *)[share menuRepresentation];
  [view setInterfaceStyle: NSWindows95InterfaceStyle];
  [shareView setInterfaceStyle: NSWindows95InterfaceStyle];

  openMenu(menu, view);
  PASS([menu isTransient] && [share isTransient]
       && [[shareView window] isVisible],
       "the menu and its submenu are both open as transient menus");

  [GSCurrentServer() setMouseLocation: centerOfItem(shareView, 0)
                             onScreen: 0];
  if (itemUnderPointer(shareView) != 0)
    {
      SKIP("the display server does not place the pointer where it is told")
    }

  releases = clickIn(shareView, centerOfItem(shareView, 0));
  PASS(releases == 1,
       "in a submenu of a transient menu, the first release ends tracking (%d releases)",
       releases);
  PASS_EQUAL(performed, @"Email",
             "and carries out the item the pointer is on");
  closeMenu(menu, view);

  openMenu(menu, view);
  releases = clickIn(view, centerOfItem(view, 0));
  PASS(releases == 2,
       "in the transient menu itself, the first release is still ignored (%d releases)",
       releases);
  PASS_EQUAL(performed, @"Copy",
             "and the next one carries out the item");
  closeMenu(menu, view);

  END_SET("NSMenuView release in a transient submenu")

  DESTROY(arp);
  (void)argc;
  (void)argv;
  return 0;
}
