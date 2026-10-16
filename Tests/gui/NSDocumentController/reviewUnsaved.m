/* -reviewUnsavedDocumentsWithAlertTitle:cancellable:delegate:
   didReviewAllSelector:contextInfo: with an edited document runs the review
   alert and tells the delegate the controller, the answer and the context.
   It used to call NSBeginAlertSheet() without its didDismissSelector, so
   the context was taken for the message format and the call raised.  The
   alert runs modally, so a timer clicks its "Quit Anyway" button.  It needs
   a backend, so the set is skipped when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSRunLoop.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSButton.h>
#include <AppKit/NSDocument.h>
#include <AppKit/NSDocumentController.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSPanel.h>
#include <AppKit/NSWindow.h>

static void
wake(void)
{
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

static NSButton *
findButton(NSView *view, NSString *title)
{
  NSEnumerator *e;
  NSView *sub;

  if ([view isKindOfClass: [NSButton class]]
    && [[(NSButton *)view title] isEqualToString: title])
    {
      return (NSButton *)view;
    }
  e = [[view subviews] objectEnumerator];
  while ((sub = [e nextObject]) != nil)
    {
      NSButton *b = findButton(sub, title);

      if (b != nil)
        {
          return b;
        }
    }
  return nil;
}

@interface Reviewer : NSObject
{
@public
  int calls;
  id controller;
  BOOL answer;
  void *context;
}
@end

@implementation Reviewer
- (void) documentController: (NSDocumentController *)c
                didReviewAll: (BOOL)flag
                 contextInfo: (void *)info
{
  calls++;
  controller = c;
  answer = flag;
  context = info;
}

- (void) quitAnyway: (id)ignored
{
  NSButton *b = findButton([[NSApp modalWindow] contentView], @"Quit Anyway");

  if (b != nil)
    {
      [b performClick: nil];
    }
  else
    {
      [NSApp stopModalWithCode: NSAlertErrorReturn];
    }
  wake();
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSDocumentController *dc;
  NSDocument *doc;
  Reviewer *reviewer;
  static int marker;
  NSArray *modes;

  START_SET("NSDocumentController reviewUnsaved")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  dc = [NSDocumentController sharedDocumentController];
  reviewer = AUTORELEASE([Reviewer new]);

  [dc reviewUnsavedDocumentsWithAlertTitle: @"Quit"
                               cancellable: YES
                                  delegate: reviewer
                      didReviewAllSelector: @selector(documentController:didReviewAll:contextInfo:)
                               contextInfo: &marker];
  PASS(reviewer->calls == 1 && reviewer->controller == dc
       && reviewer->answer == YES && reviewer->context == &marker,
       "with nothing edited the delegate is told YES at once");

  doc = AUTORELEASE([[NSDocument alloc] init]);
  [dc addDocument: doc];
  [doc updateChangeCount: NSChangeDone];
  PASS([dc hasEditedDocuments], "the controller has an edited document");

  modes = [NSArray arrayWithObject: NSModalPanelRunLoopMode];
  [reviewer performSelector: @selector(quitAnyway:)
                 withObject: nil
                 afterDelay: 0.2
                    inModes: modes];
  reviewer->calls = 0;
  reviewer->controller = nil;
  reviewer->answer = NO;
  reviewer->context = NULL;
  NS_DURING
    [dc reviewUnsavedDocumentsWithAlertTitle: @"Quit"
                                 cancellable: YES
                                    delegate: reviewer
                        didReviewAllSelector: @selector(documentController:didReviewAll:contextInfo:)
                                 contextInfo: &marker];
  NS_HANDLER
    NSLog(@"review raised %@", localException);
  NS_ENDHANDLER
  PASS(reviewer->calls == 1, "with an edited document the delegate is told");
  PASS(reviewer->controller == dc && reviewer->context == &marker,
       "the delegate gets the controller and the context");
  PASS(reviewer->answer == YES, "the delegate gets the answer of the alert");

  [doc updateChangeCount: NSChangeCleared];
  [dc removeDocument: doc];

  END_SET("NSDocumentController reviewUnsaved")

  DESTROY(arp);
  return 0;
}
