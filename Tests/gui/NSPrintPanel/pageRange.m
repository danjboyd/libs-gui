/* The print panel shows the first and last page of the print info as its
   page range.  It took the last page for the length of the range, so a
   range not starting at page 1 showed a last page too far.  The panel
   uses the current print operation's print info; making one needs the
   backend and the printing bundle, so the set is skipped without them. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSForm.h>
#include <AppKit/NSFormCell.h>
#include <AppKit/NSMatrix.h>
#include <AppKit/NSPrintInfo.h>
#include <AppKit/NSPrintOperation.h>
#include <AppKit/NSPrintPanel.h>
#include <AppKit/NSView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPrintPanel *panel = nil;
  NSPrintOperation *op = nil;
  NSMutableDictionary *dict;
  NSView *view;
  NSMatrix *matrix;
  NSForm *fromForm;
  NSForm *toForm;

  START_SET("NSPrintPanel page range")

  NS_DURING
    {
      [NSApplication sharedApplication];
      view = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 100)]);
      op = [NSPrintOperation EPSOperationWithView: view
                                       insideRect: [view bounds]
                                           toPath: [NSTemporaryDirectory()
        stringByAppendingPathComponent: @"GSTestPageRange.eps"]
                                        printInfo: AUTORELEASE([[NSPrintInfo
        alloc] initWithDictionary: nil])];
      [NSPrintOperation setCurrentOperation: op];
      panel = [NSPrintPanel printPanel];
    }
  NS_HANDLER
    {
      panel = nil;
    }
  NS_ENDHANDLER
  if (panel == nil || op == nil)
    {
      SKIP("the backend or the printing bundle is not available")
    }

  dict = [[op printInfo] dictionary];
  matrix = [[panel contentView] viewWithTag: NSPPPageChoiceMatrix];
  fromForm = [[panel contentView] viewWithTag: NSPPPageRangeFrom];
  toForm = [[panel contentView] viewWithTag: NSPPPageRangeTo];

  [dict setObject: [NSNumber numberWithInt: 2] forKey: NSPrintFirstPage];
  [dict setObject: [NSNumber numberWithInt: 4] forKey: NSPrintLastPage];
  [panel updateFromPrintInfo];
  [matrix selectCellAtRow: 0 column: 1];
  [panel pickedAllPages: matrix];

  PASS_EQUAL([[fromForm cellAtIndex: 0] stringValue], @"2",
    "the first page of the range is shown");
  PASS_EQUAL([[toForm cellAtIndex: 0] stringValue], @"4",
    "the last page of the range is shown");

  [NSPrintOperation setCurrentOperation: nil];

  END_SET("NSPrintPanel page range")

  [pool release];
  return 0;
}
