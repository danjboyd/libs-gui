/* A menu item without a user key equivalent has no user modifier mask.
   The mask was always the command key.  User key equivalents come from
   the NSCommandKeys entry of the user's global defaults; the test does not
   write those, so it uses a title no entry can have and checks only that
   case.  Menu items need no backend. */
#import "Testing.h"

#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSMenuItem.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMenuItem *item;

  START_SET("NSMenuItem userKeyEquivalentModifierMask")

  item = AUTORELEASE([[NSMenuItem alloc]
    initWithTitle: @"GSTestUserKeyItem-3f7c1d"
           action: NULL
    keyEquivalent: @""]);
  PASS([[item userKeyEquivalent] length] == 0,
    "the item has no user key equivalent");
  PASS([item userKeyEquivalentModifierMask] == 0,
    "an item without a user key equivalent has no user modifier mask");

  END_SET("NSMenuItem userKeyEquivalentModifierMask")

  [pool release];
  return 0;
}
