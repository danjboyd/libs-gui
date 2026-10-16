/* -runModalPageLayoutWithPrintInfo:delegate:didRunSelector:contextInfo:
   tells the delegate the document, whether the panel was accepted, and the
   context.  The page layout sheet used to send the delegate its own
   arguments, so the delegate got the panel as the document and the return
   code as the flag.  The panel runs modally, so a timer ends it with OK.
   It needs a backend, so the set is skipped when the backend is
   unavailable. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSRunLoop.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSDocument.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSPanel.h>
#include <AppKit/NSPrintInfo.h>

@interface LayoutRecorder : NSObject
{
@public
  int calls;
  id document;
  BOOL accepted;
  void *context;
}
@end

@implementation LayoutRecorder
- (void) document: (id)doc didRunPageLayout: (BOOL)flag contextInfo: (void *)info
{
  calls++;
  document = doc;
  accepted = flag;
  context = info;
}

- (void) accept: (id)ignored
{
  [NSApp stopModalWithCode: NSOKButton];
  [NSApp postEvent: [NSEvent otherEventWithType: NSApplicationDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: 0
                                        context: nil
                                        subtype: 0
                                          data1: 0
                                          data2: 0]
           atStart: NO];
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSDocument *doc;
  LayoutRecorder *recorder;
  NSPrintInfo *info;
  static int marker;

  START_SET("NSDocument pageLayoutDelegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  doc = AUTORELEASE([[NSDocument alloc] init]);
  recorder = AUTORELEASE([LayoutRecorder new]);
  info = AUTORELEASE([[NSPrintInfo alloc] initWithDictionary: nil]);

  [recorder performSelector: @selector(accept:)
                 withObject: nil
                 afterDelay: 0.2
                    inModes: [NSArray arrayWithObject: NSModalPanelRunLoopMode]];
  [doc runModalPageLayoutWithPrintInfo: info
                              delegate: recorder
                        didRunSelector: @selector(document:didRunPageLayout:contextInfo:)
                           contextInfo: &marker];

  PASS(recorder->calls == 1, "the delegate is told once");
  PASS(recorder->document == doc, "the delegate gets the document");
  PASS(recorder->accepted == YES, "the delegate is told the panel was accepted");
  PASS(recorder->context == &marker, "the delegate gets the context");

  END_SET("NSDocument pageLayoutDelegate")

  DESTROY(arp);
  return 0;
}
