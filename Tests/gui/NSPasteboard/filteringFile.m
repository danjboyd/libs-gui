/* A pasteboard made by +pasteboardByFilteringFile: provides the name of
   the file for the file name types it declares.  Its owner used to write
   the file's contents instead, which redeclared the pasteboard's types, so
   the declared types were lost and the file names were never provided.
   The pasteboard needs the gpbs server, so the set is skipped without it.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSException.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSString.h>
#include <AppKit/NSPasteboard.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSString *file;
  NSString *typed;
  NSPasteboard *pb = nil;
  id names = nil;

  START_SET("NSPasteboard pasteboardByFilteringFile:")

  file = [NSTemporaryDirectory()
    stringByAppendingPathComponent: @"filteringFile.txt"];
  [[@"text" dataUsingEncoding: NSUTF8StringEncoding]
    writeToFile: file atomically: NO];
  typed = NSCreateFilenamePboardType(@"txt");

  NS_DURING
    {
      pb = [NSPasteboard pasteboardByFilteringFile: file];
    }
  NS_HANDLER
    {
      pb = nil;
    }
  NS_ENDHANDLER
  if (pb == nil)
    {
      [[NSFileManager defaultManager] removeFileAtPath: file handler: nil];
      SKIP("the pasteboard server is not available")
    }

  PASS([[pb types] containsObject: NSFilenamesPboardType],
    "the filtered pasteboard declares the file names type");
  PASS([[pb types] containsObject: typed],
    "the filtered pasteboard declares the typed file names type");

  names = [pb propertyListForType: NSFilenamesPboardType];
  PASS_EQUAL(names, [NSArray arrayWithObject: file],
    "the file names type holds the name of the file");
  names = [pb propertyListForType: typed];
  PASS_EQUAL(names, [NSArray arrayWithObject: file],
    "the typed file names type holds the name of the file");
  PASS([[pb types] containsObject: NSFilenamesPboardType],
    "providing the data keeps the declared types");

  [pb releaseGlobally];
  [[NSFileManager defaultManager] removeFileAtPath: file handler: nil];

  END_SET("NSPasteboard pasteboardByFilteringFile:")

  [pool release];
  return 0;
}
