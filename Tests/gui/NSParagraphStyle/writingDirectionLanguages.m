/* Persian, Pashto and Urdu are written right to left, and Chinese left to
   right.  Two missing commas in the table of right to left languages ran
   Persian into Pashto and Urdu into its three letter code, so all three
   were taken for left to right, and the table listed Chinese as right to
   left.  The method needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSParagraphStyle.h>

static BOOL
isRTL(NSString *language)
{
  return [NSParagraphStyle defaultWritingDirectionForLanguage: language]
    == NSWritingDirectionRightToLeft;
}

int main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSParagraphStyle writing direction by language")

  PASS(isRTL(@"per") && isRTL(@"ps"), "Persian and Pashto are right to left");
  PASS(isRTL(@"ur") && isRTL(@"urd"), "Urdu is right to left");
  PASS(isRTL(@"ur_PK"), "Urdu with a region is right to left");
  PASS(!isRTL(@"zh") && !isRTL(@"zho") && !isRTL(@"chi")
    && !isRTL(@"zh_CN"), "Chinese is left to right");

  END_SET("NSParagraphStyle writing direction by language")

  [pool release];
  return 0;
}
