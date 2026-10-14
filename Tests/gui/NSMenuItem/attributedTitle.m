/* A menu item keeps the attributed title it is given, with its plain title
   in step, and a new plain title replaces the attributed one.  The
   attributed title used to be dropped, and -attributedTitle answered nil. */
#import "Testing.h"

#import <Foundation/NSAttributedString.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSString.h>
#import <AppKit/NSMenuItem.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMenuItem *item;
  NSAttributedString *title;

  START_SET("NSMenuItem attributedTitle")

  item = AUTORELEASE([[NSMenuItem alloc] initWithTitle: @"Plain"
                                                action: NULL
                                         keyEquivalent: @""]);
  PASS([item attributedTitle] == nil, "a new item has no attributed title");

  title = AUTORELEASE([[NSAttributedString alloc] initWithString: @"Fancy"]);
  [item setAttributedTitle: title];
  PASS_EQUAL([item attributedTitle], title, "the attributed title is kept");
  PASS_EQUAL([item title], @"Fancy",
    "the plain title follows the attributed title");
  PASS_EQUAL([AUTORELEASE([item copy]) attributedTitle], title,
    "a copy keeps the attributed title");
  PASS_EQUAL([[NSKeyedUnarchiver unarchiveObjectWithData:
    [NSKeyedArchiver archivedDataWithRootObject: item]] attributedTitle], title,
    "keyed archiving keeps the attributed title");

  [item setTitle: @"Plain"];
  PASS([item attributedTitle] == nil,
    "a plain title replaces the attributed title");

  END_SET("NSMenuItem attributedTitle")

  [pool release];
  return 0;
}
