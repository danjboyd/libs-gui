#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSDataLink.h>
#import <AppKit/NSDataLinkManager.h>
#import <AppKit/NSSelection.h>

/* A link manager numbers the links it takes, uniquely, and a link's
   disposition says whether it is in its source document, in its
   destination document, or broken.  Both were left at their initial values
   (number 0, in the destination).  The manager is a plain model object
   here and needs no backend. */

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSObject *doc = AUTORELEASE([NSObject new]);
  NSDataLinkManager *manager;
  NSDataLink *a;
  NSDataLink *b;
  NSDataLink *c;

  START_SET("NSDataLink number and disposition")

  manager = AUTORELEASE([[NSDataLinkManager alloc] initWithDelegate: doc]);
  a = AUTORELEASE([[NSDataLink alloc] init]);
  b = AUTORELEASE([[NSDataLink alloc] init]);
  c = AUTORELEASE([[NSDataLink alloc] init]);

  [manager addSourceLink: a];
  [manager addSourceLink: b];
  [manager addLink: c at: [NSSelection selectionWithDescriptionData:
    [@"sel" dataUsingEncoding: NSUTF8StringEncoding]]];

  PASS([a linkNumber] != 0 && [b linkNumber] != 0 && [c linkNumber] != 0
    && [a linkNumber] != [b linkNumber] && [b linkNumber] != [c linkNumber]
    && [a linkNumber] != [c linkNumber],
    "the manager gives each link its own number");
  PASS([a disposition] == NSLinkInSource, "a source link is in the source");
  PASS([c disposition] == NSLinkInDestination,
    "a destination link is in the destination");
  [b break];
  PASS([b disposition] == NSLinkBroken, "a broken link is broken");

  [manager removeLink: c];

  END_SET("NSDataLink number and disposition")

  [pool release];
  return 0;
}
