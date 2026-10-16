/* -invalidateLayoutForCharacterRange:actualCharacterRange: answers, through
   its pointer, a range that covers the characters asked for.  It used to
   leave the range unchanged.  Layout needs fonts, so the set is skipped
   when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSLayoutManager.h>
#include <AppKit/NSTextContainer.h>
#include <AppKit/NSTextStorage.h>

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSLayoutManager *lm;
  NSTextStorage *ts;
  NSTextContainer *tc;
  NSRange actual = NSMakeRange(NSNotFound, 0);

  START_SET("NSLayoutManager invalidateActualRange")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  ts = AUTORELEASE([[NSTextStorage alloc] initWithString:
    @"The quick brown fox jumps over the lazy dog, "
    @"and then the dog chases the fox all the way home."]);
  lm = AUTORELEASE([[NSLayoutManager alloc] init]);
  tc = AUTORELEASE([[NSTextContainer alloc]
    initWithContainerSize: NSMakeSize(100, 1000)]);
  [lm addTextContainer: tc];
  [ts addLayoutManager: lm];
  [lm ensureLayoutForCharacterRange: NSMakeRange(0, [ts length])];

  [lm invalidateLayoutForCharacterRange: NSMakeRange(60, 5)
                   actualCharacterRange: &actual];
  PASS(actual.location != NSNotFound && actual.location <= 60
       && NSMaxRange(actual) >= 65 && NSMaxRange(actual) <= [ts length],
       "the actual range covers the invalidated characters");
  PASS([lm firstUnlaidCharacterIndex] <= 60,
       "the characters are no longer laid out");

  [lm invalidateLayoutForCharacterRange: NSMakeRange(0, 1)
                   actualCharacterRange: NULL];
  PASS(YES, "a NULL actual range pointer is accepted");

  END_SET("NSLayoutManager invalidateActualRange")

  DESTROY(arp);
  return 0;
}
