#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSSavePanel.h>

/* A save panel reports that it is expanded, as a GNUstep save panel
   always shows its file browser.  It answered NO.  Creating the panel
   needs a backend, so this keeps the usual guard. */

int
main(int argc, const char **argv)
{
  START_SET("NSSavePanel isExpanded")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSSavePanel *p = [NSSavePanel savePanel];

      PASS([p isExpanded] == YES, "a save panel is expanded");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
  NS_ENDHANDLER

  END_SET("NSSavePanel isExpanded")
  return 0;
}
