/* A menu asks its delegate three things, as on Cocoa:
   -menuHasKeyEquivalent:forEvent:target:action: answers for a key
   equivalent instead of the menu's items, -menu:willHighlightItem: is told
   before the menu view highlights an item (nil when it unhighlights), and
   -confinementRectForMenu:onScreen: gives a rectangle a popped-up menu is
   kept inside.  None of them was sent.  Displaying a menu needs the
   backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSMenuItem.h>
#include <AppKit/NSMenuView.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>

@interface PlacementDelegate : NSObject <NSMenuDelegate>
{
@public
  int keyEquivalentAsked;
  BOOL answerKeyEquivalent;
  int actionSent;
  NSMutableArray *highlighted;
  int confinementAsked;
  NSRect confinement;
}
@end
@implementation PlacementDelegate
- (BOOL) menuHasKeyEquivalent: (NSMenu *)menu
		     forEvent: (NSEvent *)event
		       target: (id *)target
		       action: (SEL *)action
{
  keyEquivalentAsked++;
  if (answerKeyEquivalent)
    {
      *target = self;
      *action = @selector(keyAction:);
    }
  return answerKeyEquivalent;
}
- (void) keyAction: (id)sender
{
  actionSent++;
}
- (void) menu: (NSMenu *)menu willHighlightItem: (NSMenuItem *)item
{
  [highlighted addObject: item ? (id)item : (id)[NSNull null]];
}
- (NSRect) confinementRectForMenu: (NSMenu *)menu onScreen: (NSScreen *)screen
{
  confinementAsked++;
  return confinement;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  PlacementDelegate *delegate;
  NSMenu *menu;
  NSMenuView *view;
  NSWindow *window;
  NSView *host;
  NSEvent *event;
  NSRect frame;

  START_SET("NSMenu placement delegate")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 240, 160)
	      styleMask: NSTitledWindowMask
		backing: NSBackingStoreBuffered
		  defer: NO]);
  [window setReleasedWhenClosed: NO];
  host = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(20, 40, 100, 24)]);
  [[window contentView] addSubview: host];
  [window orderFront: nil];

  delegate = AUTORELEASE([PlacementDelegate new]);
  delegate->highlighted = [NSMutableArray array];
  menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Placed"]);
  [menu addItemWithTitle: @"One" action: NULL keyEquivalent: @"o"];
  [menu addItemWithTitle: @"Two" action: NULL keyEquivalent: @""];
  [menu setDelegate: delegate];

  event = [NSEvent keyEventWithType: NSKeyDown
			   location: NSZeroPoint
		      modifierFlags: NSCommandKeyMask
			  timestamp: 0
		       windowNumber: [window windowNumber]
			    context: nil
			 characters: @"z"
	charactersIgnoringModifiers: @"z"
			  isARepeat: NO
			    keyCode: 0];
  PASS([menu performKeyEquivalent: event] == NO
    && delegate->keyEquivalentAsked == 1,
    "the delegate is asked for a key equivalent and can decline it");
  delegate->answerKeyEquivalent = YES;
  PASS([menu performKeyEquivalent: event] == YES && delegate->actionSent == 1,
    "a key equivalent the delegate answers for sends its action");

  view = (NSMenuView *)[menu menuRepresentation];
  [view setHighlightedItemIndex: 1];
  [view setHighlightedItemIndex: -1];
  PASS([delegate->highlighted count] == 2
    && [delegate->highlighted objectAtIndex: 0] == [menu itemAtIndex: 1]
    && [delegate->highlighted objectAtIndex: 1] == [NSNull null],
    "the delegate is told which item will be highlighted, then of none");

  delegate->confinement = NSMakeRect(600, 0, 400, 400);
  [menu popUpMenuPositioningItem: nil
		      atLocation: NSMakePoint(0, 0)
			  inView: host];
  frame = [[menu window] frame];
  PASS(delegate->confinementAsked >= 1 && NSMinX(frame) >= 600,
    "a popped-up menu is kept inside the delegate's rectangle");
  [menu close];

  END_SET("NSMenu placement delegate")

  [pool release];
  return 0;
}
