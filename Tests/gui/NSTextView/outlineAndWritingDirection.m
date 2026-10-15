/* NSTextView -outline: gives the selection a stroke width, and removes it
   when the selection is already outlined; -toggleBaseWritingDirection:
   makes the selected paragraphs and the typing attributes right to left,
   and left to right again.  Both were empty stubs.  NSTextView needs the
   text system and the font backend, so the set is skipped when the
   backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSRange.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSAttributedString.h>
#include <AppKit/NSParagraphStyle.h>
#include <AppKit/NSTextView.h>
#include <AppKit/NSTextStorage.h>

static NSWritingDirection
direction(NSTextView *tv, NSUInteger index)
{
  NSParagraphStyle *style = [[tv textStorage]
    attribute: NSParagraphStyleAttributeName
      atIndex: index
    effectiveRange: NULL];

  return style == nil ? NSWritingDirectionNatural
    : [style baseWritingDirection];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTextView *tv;
  NSTextStorage *ts;

  START_SET("NSTextView outline and writing direction")

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

  tv = AUTORELEASE([[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  [tv setString: @"alpha beta"];
  ts = [tv textStorage];

  [tv setSelectedRange: NSMakeRange(0, 5)];
  [tv outline: nil];
  PASS([[ts attribute: NSStrokeWidthAttributeName atIndex: 0
    effectiveRange: NULL] floatValue] > 0.0,
    "outline: gives the selection a stroke width");
  PASS([ts attribute: NSStrokeWidthAttributeName atIndex: 6
    effectiveRange: NULL] == nil,
    "the text outside the selection is not outlined");
  [tv outline: nil];
  PASS([ts attribute: NSStrokeWidthAttributeName atIndex: 0
    effectiveRange: NULL] == nil,
    "outline: again removes the outline");

  [tv toggleBaseWritingDirection: nil];
  PASS(direction(tv, 0) == NSWritingDirectionRightToLeft,
    "toggleBaseWritingDirection: makes the paragraph right to left");
  [tv toggleBaseWritingDirection: nil];
  PASS(direction(tv, 0) == NSWritingDirectionLeftToRight,
    "toggleBaseWritingDirection: again makes it left to right");

  [tv setSelectedRange: NSMakeRange([ts length], 0)];
  [tv toggleBaseWritingDirection: nil];
  PASS([[[tv typingAttributes] objectForKey: NSParagraphStyleAttributeName]
    baseWritingDirection] == NSWritingDirectionRightToLeft,
    "at the end of the text the typing attributes become right to left");
  [tv toggleBaseWritingDirection: nil];
  PASS([[[tv typingAttributes] objectForKey: NSParagraphStyleAttributeName]
    baseWritingDirection] == NSWritingDirectionLeftToRight,
    "and left to right again");

  END_SET("NSTextView outline and writing direction")

  [pool release];
  return 0;
}
