/* -commitEditingWithDelegate:didCommitSelector:contextInfo: commits the
   edits with -commitEditing and tells the delegate the view controller as
   the editor, with the result and the context.  It used to pass nil as the
   editor. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSViewController.h>

@interface CommittingController : NSViewController
@end

@implementation CommittingController
- (BOOL) commitEditing
{
  return YES;
}
@end

@interface CommitDelegate : NSObject
{
@public
  int calls;
  id editor;
  BOOL committed;
  void *context;
}
@end

@implementation CommitDelegate
- (void) editor: (id)e didCommit: (BOOL)flag contextInfo: (void *)info
{
  calls++;
  editor = e;
  committed = flag;
  context = info;
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  CommittingController *vc;
  CommitDelegate *d;
  static int marker;

  START_SET("NSViewController commitEditing")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  vc = AUTORELEASE([[CommittingController alloc] initWithNibName: nil
                                                          bundle: nil]);
  d = AUTORELEASE([CommitDelegate new]);
  [vc commitEditingWithDelegate: d
              didCommitSelector: @selector(editor:didCommit:contextInfo:)
                    contextInfo: &marker];

  PASS(d->calls == 1, "the delegate is told once");
  PASS(d->editor == vc, "the delegate gets the view controller as the editor");
  PASS(d->committed == YES && d->context == &marker,
       "the delegate gets the result and the context");

  END_SET("NSViewController commitEditing")

  DESTROY(arp);
  return 0;
}
