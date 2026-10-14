/* A text view's delegate is told when the typing attributes change, as it
   is told of the other text view notifications.  -setDelegate: did not
   register the delegate for this one, so it was never told.  The text
   view lays out through the theme and font backend, so the set is skipped
   when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSNotification.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSAttributedString.h>
#include <AppKit/NSFont.h>
#include <AppKit/NSTextView.h>

@interface TypingDelegate : NSObject
{
@public
  int count;
}
@end

@implementation TypingDelegate
- (void) textViewDidChangeTypingAttributes: (NSNotification *)n
{
  count++;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  TypingDelegate *d;
  NSTextView *tv;

  START_SET("NSTextView typing attributes delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  d = AUTORELEASE([TypingDelegate new]);
  tv = AUTORELEASE([[NSTextView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  [tv setDelegate: d];
  [tv setTypingAttributes: [NSDictionary dictionaryWithObject:
    [NSColor redColor] forKey: NSForegroundColorAttributeName]];
  PASS(d->count == 1, "the delegate is told that the typing attributes changed");
  [tv setDelegate: nil];

  END_SET("NSTextView typing attributes delegate")

  [pool release];
  return 0;
}
