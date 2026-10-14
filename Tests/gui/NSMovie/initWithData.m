/* A movie made from data writes the data to a temporary file and keeps the
   URL of that file, which it removes when it is deallocated.  The URL used
   to be autoreleased but not retained, so it dangled once the autorelease
   pool was drained, and was released again by -dealloc.  A movie is a plain
   model object and needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSString.h>
#include <Foundation/NSURL.h>

#include <AppKit/NSMovie.h>

@interface NSMovie (InitWithData)
- (instancetype) initWithData: (NSData *)movie;
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSAutoreleasePool *inner;
  NSData *data = [@"movie" dataUsingEncoding: NSUTF8StringEncoding];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *path;
  NSMovie *movie;

  START_SET("NSMovie initWithData:")

  inner = [NSAutoreleasePool new];
  movie = [[NSMovie alloc] initWithData: data];
  [inner release];

  PASS([[movie URL] isFileURL], "the movie keeps the URL of its file");
  path = AUTORELEASE([[[movie URL] path] copy]);
  PASS([[NSData dataWithContentsOfFile: path] isEqual: data],
    "the file holds the movie data");

  RELEASE(movie);
  PASS([fm fileExistsAtPath: path] == NO,
    "the file is removed when the movie is deallocated");

  PASS([[NSMovie alloc] initWithURL: nil byReference: NO] == nil,
    "a movie cannot be made from a nil URL");

  END_SET("NSMovie initWithData:")

  [pool release];
  return 0;
}
