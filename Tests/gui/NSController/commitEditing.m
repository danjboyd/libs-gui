/* -commitEditingWithDelegate:didCommitSelector:contextInfo: commits every
   registered editor and tells the delegate once, with the controller, the
   combined result and the context.  It used to tell the delegate once per
   editor, so with no editor it never told it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSController.h>

@interface Editor : NSObject
{
@public
  BOOL answer;
  int commits;
}
@end

@implementation Editor
- (BOOL) commitEditing
{
  commits++;
  return answer;
}
@end

@interface CommitDelegate : NSObject
{
@public
  int calls;
  id controller;
  BOOL committed;
  void *context;
}
@end

@implementation CommitDelegate
- (void) editor: (id)c didCommit: (BOOL)flag contextInfo: (void *)info
{
  calls++;
  controller = c;
  committed = flag;
  context = info;
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSController *c;
  CommitDelegate *d;
  Editor *e1, *e2;
  static int marker;

  START_SET("NSController commitEditing")

  c = AUTORELEASE([[NSController alloc] init]);
  d = AUTORELEASE([CommitDelegate new]);
  [c commitEditingWithDelegate: d
             didCommitSelector: @selector(editor:didCommit:contextInfo:)
                   contextInfo: &marker];
  PASS(d->calls == 1 && d->controller == c && d->committed == YES
       && d->context == &marker,
       "with no editor the delegate is told the controller committed");

  e1 = AUTORELEASE([Editor new]);
  e2 = AUTORELEASE([Editor new]);
  e1->answer = YES;
  e2->answer = YES;
  [c objectDidBeginEditing: e1];
  [c objectDidBeginEditing: e2];
  d->calls = 0;
  [c commitEditingWithDelegate: d
             didCommitSelector: @selector(editor:didCommit:contextInfo:)
                   contextInfo: &marker];
  PASS(e1->commits == 1 && e2->commits == 1, "every editor commits");
  PASS(d->calls == 1 && d->committed == YES,
       "with two editors the delegate is told once");

  e2->answer = NO;
  d->calls = 0;
  [c commitEditingWithDelegate: d
             didCommitSelector: @selector(editor:didCommit:contextInfo:)
                   contextInfo: &marker];
  PASS(d->calls == 1 && d->committed == NO,
       "the delegate is told NO when an editor fails to commit");

  END_SET("NSController commitEditing")

  DESTROY(arp);
  return 0;
}
