/* -clickedOnLink:atIndex: tells a delegate implementing only the older
   textView:clickedOnLink: about the link, and prefers the newer form with
   the index when the delegate has it.  A click on a link in -mouseDown:
   goes through the same private method, which answers whether the
   delegate handled the click.  The older form used to be ignored.
   The text view lays out through the theme and font backend, so the set is
   skipped when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTextView.h>

@interface NSTextView (GSClickedOnLink)
- (BOOL) _sendClickedOnLink: (id)link atIndex: (NSUInteger)charIndex;
@end

@interface OldLinkDelegate : NSObject
{
@public
  id link;
}
@end

@implementation OldLinkDelegate
- (BOOL) textView: (NSTextView *)tv clickedOnLink: (id)l
{
  link = l;
  return YES;
}
@end

@interface NewLinkDelegate : OldLinkDelegate
{
@public
  NSUInteger index;
}
@end

@implementation NewLinkDelegate
- (BOOL) textView: (NSTextView *)tv clickedOnLink: (id)l atIndex: (NSUInteger)i
{
  index = i;
  return YES;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  OldLinkDelegate *oldDelegate;
  NewLinkDelegate *newDelegate;
  NSTextView *tv;

  START_SET("NSTextView clickedOnLink: delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTextView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 100)]);

  oldDelegate = AUTORELEASE([OldLinkDelegate new]);
  [tv setDelegate: oldDelegate];
  [tv clickedOnLink: @"link" atIndex: 3];
  PASS_EQUAL(oldDelegate->link, @"link",
    "a delegate with only textView:clickedOnLink: is told of the link");
  oldDelegate->link = nil;
  PASS([tv _sendClickedOnLink: @"click" atIndex: 0] == YES
    && [oldDelegate->link isEqual: @"click"],
    "a click on a link tells a delegate with only the older form");

  newDelegate = AUTORELEASE([NewLinkDelegate new]);
  [tv setDelegate: newDelegate];
  [tv clickedOnLink: @"link" atIndex: 3];
  PASS(newDelegate->index == 3 && newDelegate->link == nil,
    "a delegate with textView:clickedOnLink:atIndex: is told with the index");

  [tv setDelegate: nil];

  END_SET("NSTextView clickedOnLink: delegate")

  [pool release];
  return 0;
}
