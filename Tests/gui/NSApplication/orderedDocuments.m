/* -[NSApplication orderedDocuments] answers the documents of the windows
   on screen, front to back, each once.  It answered nil.  A document whose
   window is not on screen is left out.  The windows need the backend, so
   the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSDocument.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSWindowController.h>

static NSWindow *
documentWindow(NSDocument *doc)
{
  NSWindow *w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 120, 80)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  NSWindowController *wc = AUTORELEASE([[NSWindowController alloc]
    initWithWindow: w]);

  [doc addWindowController: wc];
  return w;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSDocument *a;
  NSDocument *b;
  NSDocument *hidden;
  NSWindow *wa;
  NSWindow *wb;
  NSArray *docs;
  NSArray *windows;

  START_SET("NSApplication orderedDocuments")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  a = AUTORELEASE([[NSDocument alloc] init]);
  b = AUTORELEASE([[NSDocument alloc] init]);
  hidden = AUTORELEASE([[NSDocument alloc] init]);
  wa = documentWindow(a);
  wb = documentWindow(b);
  documentWindow(hidden);
  [wa orderFront: nil];
  [wb orderFront: nil];

  docs = [NSApp orderedDocuments];
  windows = [NSApp orderedWindows];
  PASS(docs != nil, "the ordered documents are an array");
  PASS([docs indexOfObjectIdenticalTo: hidden] == NSNotFound,
    "a document without a window on screen is left out");
  if ([windows containsObject: wa] && [windows containsObject: wb])
    {
      PASS([docs count] >= 2
        && ([docs indexOfObjectIdenticalTo: a] < [docs indexOfObjectIdenticalTo: b])
          == ([windows indexOfObjectIdenticalTo: wa]
            < [windows indexOfObjectIdenticalTo: wb]),
        "the documents are in the order of their windows");
    }

  [wa orderOut: nil];
  [wb orderOut: nil];

  END_SET("NSApplication orderedDocuments")

  [pool release];
  return 0;
}
