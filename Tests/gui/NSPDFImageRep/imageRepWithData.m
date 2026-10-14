#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <AppKit/NSPDFImageRep.h>
#import <AppKit/NSPICTImageRep.h>

/* +imageRepWithData: answers an autoreleased rep, which the caller does not
   own.  NSPDFImageRep and NSPICTImageRep used to answer a rep they had
   allocated without autoreleasing it, so it leaked. */

static BOOL
answersAutoreleased(Class repClass)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  id rep = [repClass imageRepWithData: [NSData data]];
  BOOL autoreleased;

  RETAIN(rep);
  [pool release];
  autoreleased = (rep == nil || [rep retainCount] == 1);
  RELEASE(rep);
  return autoreleased;
}

int
main(int argc, const char **argv)
{
  START_SET("imageRepWithData: ownership")

  PASS(answersAutoreleased([NSPDFImageRep class]),
    "+[NSPDFImageRep imageRepWithData:] answers an autoreleased rep");
  PASS(answersAutoreleased([NSPICTImageRep class]),
    "+[NSPICTImageRep imageRepWithData:] answers an autoreleased rep");

  END_SET("imageRepWithData: ownership")
  return 0;
}
