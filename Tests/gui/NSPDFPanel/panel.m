/* +[NSPDFPanel panel] answers an initialized panel, with the default
   options and file name of -init.  It answered an object that was only
   allocated, so its options were 0 and its file name nil.  The panel
   shows nothing here and needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>
#include <AppKit/NSPDFPanel.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPDFPanel *panel;

  START_SET("NSPDFPanel panel")

  panel = [NSPDFPanel panel];
  PASS(panel != nil, "a panel is made");
  PASS([panel options] == NSPDFPanelShowsPaperSize,
    "the panel has the default options");
  PASS_EQUAL([panel defaultFileName], @"",
    "the panel has an empty default file name");

  [panel setDefaultFileName: @"report.pdf"];
  PASS_EQUAL([panel defaultFileName], @"report.pdf",
    "the default file name is kept");

  END_SET("NSPDFPanel panel")

  [pool release];
  return 0;
}
