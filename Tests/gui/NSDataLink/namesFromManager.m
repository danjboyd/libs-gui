#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSDataLink.h>
#import <AppKit/NSDataLinkManager.h>
#import <AppKit/NSSelection.h>

/* A link added to a manager takes the manager's document as its
   destination file and the running application as its destination
   application, or as its source application for a source link, and the
   links follow their document when it is saved under a new name.  The destination file name and the application names were
   never set.  The manager is a plain model object here and needs no
   backend. */

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSObject *doc = AUTORELEASE([NSObject new]);
  NSString *app = [[NSProcessInfo processInfo] processName];
  NSDataLinkManager *manager;
  NSDataLink *source;
  NSDataLink *destination;

  START_SET("NSDataLink names from its manager")

  manager = AUTORELEASE([[NSDataLinkManager alloc]
    initWithDelegate: doc fromFile: @"/tmp/GSTestLinkDocument"]);
  source = AUTORELEASE([[NSDataLink alloc] init]);
  destination = AUTORELEASE([[NSDataLink alloc] init]);

  [manager addSourceLink: source];
  [manager addLink: destination at: [NSSelection selectionWithDescriptionData:
    [@"sel" dataUsingEncoding: NSUTF8StringEncoding]]];

  PASS_EQUAL([source sourceApplicationName], app,
    "a source link names the running application as its source");
  PASS_EQUAL([source sourceFilename], @"/tmp/GSTestLinkDocument",
    "a source link without a source file takes the manager's document");
  PASS_EQUAL([destination destinationApplicationName], app,
    "a destination link names the running application as its destination");
  PASS_EQUAL([destination destinationFilename], @"/tmp/GSTestLinkDocument",
    "a destination link takes the manager's document as its destination");

  [manager noteDocumentSavedAs: @"/tmp/GSTestLinkDocument2"];
  PASS_EQUAL([destination destinationFilename], @"/tmp/GSTestLinkDocument2",
    "a destination link follows its document to a new name");
  PASS_EQUAL([source sourceFilename], @"/tmp/GSTestLinkDocument2",
    "a source link follows its document to a new name");

  [manager removeLink: destination];

  END_SET("NSDataLink names from its manager")

  [pool release];
  return 0;
}
