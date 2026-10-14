#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSDataLink.h>
#import <AppKit/NSDataLinkManager.h>
#import <AppKit/NSSelection.h>

/* A data link manager is edited once its document or its links change, and
   no longer once the document is saved or reverted.  Nothing used to set
   the flag, so -isEdited always answered NO.  The manager is a plain model
   object here and needs no backend. */

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSObject *doc = AUTORELEASE([NSObject new]);
  NSDataLinkManager *manager;
  NSDataLink *link;
  NSSelection *sel;

  START_SET("NSDataLinkManager isEdited")

  manager = AUTORELEASE([[NSDataLinkManager alloc] initWithDelegate: doc]);
  PASS([manager isEdited] == NO, "a new manager is not edited");

  [manager noteDocumentEdited];
  PASS([manager isEdited] == YES, "editing the document edits the manager");
  [manager noteDocumentSaved];
  PASS([manager isEdited] == NO, "saving the document clears the edit");

  sel = [NSSelection selectionWithDescriptionData:
    [@"sel" dataUsingEncoding: NSUTF8StringEncoding]];
  link = AUTORELEASE([[NSDataLink alloc] init]);
  [manager addLink: link at: sel];
  PASS([manager isEdited] == YES, "adding a link edits the manager");
  [manager noteDocumentReverted];
  PASS([manager isEdited] == NO, "reverting the document clears the edit");
  [manager removeLink: link];
  PASS([manager isEdited] == YES, "removing a link edits the manager");

  END_SET("NSDataLinkManager isEdited")

  [pool release];
  return 0;
}
