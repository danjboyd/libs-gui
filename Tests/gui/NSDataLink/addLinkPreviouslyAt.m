#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSDataLink.h>
#import <AppKit/NSDataLinkManager.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSSelection.h>

/* -[NSDataLinkManager addLinkPreviouslyAt:fromPasteboard:at:] adds the link
   on the pasteboard whose destination was the old selection, now at the new
   selection, and answers it.  The method used to answer nil without adding
   anything, and it read the pasteboard as an array of links although
   -[NSDataLink writeToPasteboard:] writes a single link. */

static NSSelection *
selection(NSString *s)
{
  return [NSSelection selectionWithDescriptionData:
    [s dataUsingEncoding: NSUTF8StringEncoding]];
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSObject *doc = AUTORELEASE([NSObject new]);
  NSDataLinkManager *source;
  NSDataLinkManager *destination;
  NSDataLink *link;
  NSDataLink *added;
  NSPasteboard *pb;

  START_SET("NSDataLinkManager addLinkPreviouslyAt:fromPasteboard:at:")

  source = AUTORELEASE([[NSDataLinkManager alloc] initWithDelegate: doc]);
  link = AUTORELEASE([[NSDataLink alloc] init]);
  [source addLink: link at: selection(@"old")];

  destination = AUTORELEASE([[NSDataLinkManager alloc] initWithDelegate: doc]);

  pb = nil;
  NS_DURING
    {
      pb = [NSPasteboard pasteboardWithUniqueName];
      [link writeToPasteboard: pb];
    }
  NS_HANDLER
    SKIP("pasteboard server is not available")
  NS_ENDHANDLER

  NS_DURING
    {

      added = [destination addLinkPreviouslyAt: selection(@"elsewhere")
				fromPasteboard: pb
					    at: selection(@"new")];
      PASS(added == nil,
	"no link is added for a selection the pasteboard's link was not at");

      added = [destination addLinkPreviouslyAt: selection(@"old")
				fromPasteboard: pb
					    at: selection(@"new")];
      PASS(added != nil, "the link that was at the old selection is answered");
      PASS_EQUAL([added destinationSelection], selection(@"new"),
	"the link is at the new selection");
      PASS([[[destination destinationLinkEnumerator] allObjects]
	containsObject: added], "the manager holds the link");

      [pb declareTypes: [NSArray arrayWithObject: NSStringPboardType]
		 owner: nil];
      PASS([destination addLinkPreviouslyAt: selection(@"old")
			     fromPasteboard: pb
					 at: selection(@"new")] == nil,
	"a pasteboard without link data adds nothing");
      [pb releaseGlobally];
    }
  NS_HANDLER
    PASS(NO, "reading the pasteboard raises %s",
      [[localException reason] UTF8String]);
  NS_ENDHANDLER

  END_SET("NSDataLinkManager addLinkPreviouslyAt:fromPasteboard:at:")

  [pool release];
  return 0;
}
