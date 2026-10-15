/* EPS and PDF operations make data for copying, so they answer YES from
   -isCopyingOperation.  Every operation answered NO.  Making an operation
   needs the backend and the printing bundle, so the set is skipped
   without them.  The operations are made but not run; only one operation
   may be current for a thread, so the first is cleared before the second
   is made. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSPrintInfo.h>
#include <AppKit/NSPrintOperation.h>
#include <AppKit/NSView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPrintOperation *eps;
  NSPrintOperation *pdf;
  NSView *view;
  NSPrintInfo *info;

  START_SET("NSPrintOperation isCopyingOperation")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  view = AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 100)]);
  info = AUTORELEASE([[NSPrintInfo alloc] initWithDictionary: nil]);
  eps = [NSPrintOperation EPSOperationWithView: view
                                    insideRect: [view bounds]
                                        toData: [NSMutableData data]
                                     printInfo: info];
  if (eps == nil)
    {
      SKIP("the printing bundle is not available")
    }
  PASS([eps isCopyingOperation], "an EPS operation is a copying operation");
  PASS([NSPrintOperation currentOperation] == eps,
    "a new operation is the current operation");

  [NSPrintOperation setCurrentOperation: nil];
  pdf = [NSPrintOperation PDFOperationWithView: view
                                    insideRect: [view bounds]
                                        toData: [NSMutableData data]
                                     printInfo: info];
  PASS([pdf isCopyingOperation], "a PDF operation is a copying operation");
  [NSPrintOperation setCurrentOperation: nil];

  END_SET("NSPrintOperation isCopyingOperation")

  [pool release];
  return 0;
}
