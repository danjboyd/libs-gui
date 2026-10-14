/* -setParagraphStyle: replaces the text blocks and text lists of the
   receiver with those of the style, even when the style has none.  They
   were only copied when the style had some, so a receiver kept its own
   blocks and lists and no longer equalled the style.  Paragraph styles
   need no backend. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSParagraphStyle.h>
#include <AppKit/NSTextList.h>
#include <AppKit/NSTextTable.h>

int main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSMutableParagraphStyle *style;
  NSParagraphStyle *plain = [NSParagraphStyle defaultParagraphStyle];

  START_SET("NSMutableParagraphStyle setParagraphStyle: blocks and lists")

  style = AUTORELEASE([[NSMutableParagraphStyle alloc] init]);
  [style setTextBlocks: [NSArray arrayWithObject:
    AUTORELEASE([[NSTextBlock alloc] init])]];
  [style setTextLists: [NSArray arrayWithObject:
    AUTORELEASE([[NSTextList alloc] initWithMarkerFormat: @"{disc}"
                                                 options: 0])]];
  [style setParagraphStyle: plain];

  PASS([[style textBlocks] count] == 0,
    "the text blocks are replaced by the style's, which has none");
  PASS([[style textLists] count] == 0,
    "the text lists are replaced by the style's, which has none");
  PASS([style isEqual: plain], "the receiver then equals the style");

  END_SET("NSMutableParagraphStyle setParagraphStyle: blocks and lists")

  [pool release];
  return 0;
}
