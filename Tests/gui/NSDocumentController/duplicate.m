/* -[NSDocumentController duplicateDocumentWithContentsOfURL:copying:
   displayName:error:] opens an untitled document with the contents of the
   file, read from a copy when asked to copy, with the display name, and
   adds it to the controller.  It used to answer nil.  The controller here
   knows a single document type and makes no windows.  It needs a backend,
   so the set is skipped when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSURL.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSDocument.h>
#include <AppKit/NSDocumentController.h>

@interface TextDocument : NSDocument
{
@public
  NSString *text;
  NSURL *readFrom;
}
@end

@implementation TextDocument
- (void) dealloc
{
  RELEASE(text);
  RELEASE(readFrom);
  [super dealloc];
}
- (BOOL) readFromURL: (NSURL *)url ofType: (NSString *)type error: (NSError **)e
{
  ASSIGN(readFrom, url);
  return [super readFromURL: url ofType: type error: e];
}
- (BOOL) readFromData: (NSData *)data ofType: (NSString *)type error: (NSError **)e
{
  text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  return YES;
}
@end

@interface Controller : NSDocumentController
@end

@implementation Controller
- (NSString *) typeForContentsOfURL: (NSURL *)url error: (NSError **)e
{
  return @"Text";
}
- (Class) documentClassForType: (NSString *)type
{
  return [TextDocument class];
}
- (BOOL) shouldCreateUI
{
  return NO;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSFileManager *mgr = [NSFileManager defaultManager];
  Controller *controller;
  TextDocument *doc;
  NSString *dir;
  NSString *path;
  NSURL *url;
  NSError *error = nil;

  START_SET("NSDocumentController duplicateDocumentWithContentsOfURL:...")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  [mgr createDirectoryAtPath: dir attributes: nil];
  path = [dir stringByAppendingPathComponent: @"original.txt"];
  [[@"hello" dataUsingEncoding: NSUTF8StringEncoding]
    writeToFile: path atomically: NO];
  url = [NSURL fileURLWithPath: path];

  controller = AUTORELEASE([[Controller alloc] init]);

  doc = [controller duplicateDocumentWithContentsOfURL: url
					       copying: YES
					   displayName: @"Copy of original"
						 error: &error];
  PASS(doc != nil, "a duplicate is made by copying");
  PASS_EQUAL(doc->text, @"hello", "the duplicate has the file's contents");
  PASS([doc fileURL] == nil, "the duplicate is untitled");
  PASS(doc->readFrom != nil && [doc->readFrom isEqual: url] == NO,
    "a copying duplicate is read from a copy of the file");
  PASS([mgr contentsEqualAtPath: [doc->readFrom path] andPath: path],
    "the copy has the file's contents");
  PASS_EQUAL([doc displayName], @"Copy of original",
    "the duplicate has the display name");
  PASS([[controller documents] containsObject: doc],
    "the duplicate is added to the controller");

  doc = [controller duplicateDocumentWithContentsOfURL: url
					       copying: NO
					   displayName: nil
						 error: &error];
  PASS(doc != nil && [doc->readFrom isEqual: url],
    "a duplicate made without copying reads the file itself");
  PASS([doc fileURL] == nil, "that duplicate is untitled too");

  doc = [controller duplicateDocumentWithContentsOfURL:
    [NSURL fileURLWithPath: [dir stringByAppendingPathComponent: @"missing"]]
					       copying: YES
					   displayName: nil
						 error: &error];
  PASS(doc == nil, "a missing file is not duplicated");

  [mgr removeFileAtPath: dir handler: nil];

  END_SET("NSDocumentController duplicateDocumentWithContentsOfURL:...")

  [pool release];
  return 0;
}
