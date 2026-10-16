/* The services manager, which receives the application's file open
   requests, sends a delegate that implements application:openTempFile:
   that message for a temporary file, and leaves the file to it.  It used to
   send application:openFile: instead and remove the file. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <GNUstepGUI/GSServicesManager.h>

@interface TempDelegate : NSObject
{
@public
  int tempFiles;
  int files;
  NSString *opened;
}
@end

@implementation TempDelegate
- (BOOL) application: (NSApplication *)app openFile: (NSString *)file
{
  files++;
  return YES;
}
- (BOOL) application: (NSApplication *)app openTempFile: (NSString *)file
{
  tempFiles++;
  opened = file;
  return YES;
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  TempDelegate *d;
  NSString *path;
  NSFileManager *fm = [NSFileManager defaultManager];
  BOOL ok;

  START_SET("NSApplication openTempFile")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  path = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [NSString stringWithFormat: @"GSTestTempFile%d.txt",
      [[NSProcessInfo processInfo] processIdentifier]]];
  [@"temporary" writeToFile: path atomically: NO];

  d = AUTORELEASE([TempDelegate new]);
  [NSApp setDelegate: (id<NSApplicationDelegate>)d];
  ok = [[GSServicesManager manager] application: NSApp openTempFile: path];
  [NSApp setDelegate: nil];

  PASS(ok && d->tempFiles == 1 && d->files == 0
       && [d->opened isEqualToString: path],
       "the delegate is sent application:openTempFile:");
  PASS([fm fileExistsAtPath: path],
       "the file is left to the delegate to remove");

  [fm removeFileAtPath: path handler: nil];

  END_SET("NSApplication openTempFile")

  DESTROY(arp);
  return 0;
}
