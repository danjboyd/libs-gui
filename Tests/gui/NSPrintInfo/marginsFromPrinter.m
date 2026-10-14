/* Choosing a paper takes the margins from the printer's imageable area
   for it: the left margin from its x origin and the bottom margin from its
   y origin.  The two were swapped.  A printer subclass gives an area whose
   margins all differ.  Print info needs the printing bundle but no
   printer. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSPrinter.h>
#include <AppKit/NSPrintInfo.h>

@interface AsymmetricPrinter : NSPrinter
@end

@implementation AsymmetricPrinter
/* NSPrinter answers an instance of the printing bundle's class.  */
+ (id) allocWithZone: (NSZone *)zone
{
  return NSAllocateObject(self, 0, zone);
}
- (NSSize) pageSizeForPaper: (NSString *)paperName
{
  return NSMakeSize(600, 800);
}
- (NSRect) imageRectForPaper: (NSString *)paperName
{
  return NSMakeRect(10, 40, 570, 740);
}
@end

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPrintInfo *info;
  NSPrinter *printer;

  START_SET("NSPrintInfo margins from the printer")

  info = AUTORELEASE([[NSPrintInfo alloc] initWithDictionary: nil]);
  if (info == nil)
    {
      SKIP("the printing bundle is not available")
    }
  printer = AUTORELEASE([[AsymmetricPrinter alloc] initWithName: @"asym"
                                                       withType: @"test"
                                                       withHost: @"localhost"
                                                       withNote: @""]);
  [info setPrinter: printer];
  [info setPaperName: @"A4"];

  PASS([info leftMargin] == 10, "the left margin is the area's x origin");
  PASS([info bottomMargin] == 40, "the bottom margin is the area's y origin");
  PASS([info rightMargin] == 20, "the right margin is what is left of the width");
  PASS([info topMargin] == 20, "the top margin is what is left of the height");

  END_SET("NSPrintInfo margins from the printer")

  [pool release];
  return 0;
}
