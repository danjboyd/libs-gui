/* +imageRepsWithPasteboard: skips a class that makes no image rep from the
   pasteboard data.  It used to test the class instead of the rep it made,
   and so added nil to its result, which raised.  The pasteboard needs the
   gpbs server, so the set is skipped without it.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSException.h>
#include <Foundation/NSString.h>
#include <AppKit/NSImageRep.h>
#include <AppKit/NSPasteboard.h>

static NSString *testType = @"GSTestNoImageRepPboardType";

@interface NoRep : NSImageRep
@end

@implementation NoRep
+ (NSArray *) imagePasteboardTypes
{
  return [NSArray arrayWithObject: testType];
}

+ (id) imageRepWithData: (NSData *)data
{
  return nil;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPasteboard *pb = nil;
  NSArray *reps = [NSArray array];

  START_SET("NSImageRep imageRepsWithPasteboard:")

  NS_DURING
    {
      pb = [NSPasteboard pasteboardWithUniqueName];
      [pb declareTypes: [NSArray arrayWithObject: testType] owner: nil];
      [pb setData: [NSData dataWithBytes: "x" length: 1] forType: testType];
    }
  NS_HANDLER
    {
      pb = nil;
    }
  NS_ENDHANDLER
  if (pb == nil)
    {
      SKIP("the pasteboard server is not available")
    }

  PASS_RUNS(reps = [NoRep imageRepsWithPasteboard: pb],
    "a class making no rep from the data does not make the method raise");
  PASS(reps == nil, "no reps are answered when no rep could be made");

  [pb releaseGlobally];

  END_SET("NSImageRep imageRepsWithPasteboard:")

  [pool release];
  return 0;
}
