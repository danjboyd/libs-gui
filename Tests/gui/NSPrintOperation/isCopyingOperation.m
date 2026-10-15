/* EPS and PDF operations make data for copying, so they answer YES from
   -isCopyingOperation.  Every operation answered NO.  Making an operation
   needs the backend and the printing bundle, so the set is skipped
   without them.  The operations are made but not run. */
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
  NSPrintOperation *eps = nil;
  NSPrintOperation *pdf = nil;
  NSView *view;
  NSPrintInfo *info;

  START_SET("NSPrintOperation isCopyingOperation")

  NS_DURING
    {
      [NSApplication sharedApplication];
      view = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 100)]);
      info = AUTORELEASE([[NSPrintInfo alloc] initWithDictionary: nil]);
      eps = [NSPrintOperation EPSOperationWithView: view
                                        insideRect: [view bounds]
                                            toData: [NSMutableData data]
                                         printInfo: info];
      pdf = [NSPrintOperation PDFOperationWithView: view
                                        insideRect: [view bounds]
                                            toData: [NSMutableData data]
                                         printInfo: info];
    }
  NS_HANDLER
    {
      eps = nil;
    }
  NS_ENDHANDLER
  if (eps == nil || pdf == nil)
    {
      SKIP("the backend or the printing bundle is not available")
    }

  PASS([eps isCopyingOperation], "an EPS operation is a copying operation");
  PASS([pdf isCopyingOperation], "a PDF operation is a copying operation");

  END_SET("NSPrintOperation isCopyingOperation")

  [pool release];
  return 0;
}
