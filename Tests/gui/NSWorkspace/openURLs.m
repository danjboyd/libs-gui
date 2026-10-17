/* -openURLs:withAppBundleIdentifier:options:additionalEventParamDescriptor:
   launchIdentifiers: opens each file URL with the application the
   identifier names.  The method used to be a stub that answered NO.  The
   application here is a wrapper whose executable records the files it is
   asked to open.  The workspace needs the backend, so the set is skipped
   without it. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSDate.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSRunLoop.h>
#include <Foundation/NSURL.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSWorkspace.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSFileManager *mgr = [NSFileManager defaultManager];
  NSWorkspace *ws;
  NSString *dir;
  NSString *app;
  NSString *log;
  NSString *first;
  NSString *second;
  NSString *opened = nil;
  NSArray *identifiers = (id)@"unset";
  NSArray *urls;
  NSDate *limit;
  BOOL ok;

  START_SET("NSWorkspace openURLs:withAppBundleIdentifier:...")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  ws = [NSWorkspace sharedWorkspace];
  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  app = [dir stringByAppendingPathComponent: @"Opener.app"];
  log = [dir stringByAppendingPathComponent: @"opened.log"];
  [mgr createDirectoryAtPath: dir attributes: nil];
  [mgr createDirectoryAtPath: app attributes: nil];
  [[NSDictionary dictionaryWithObject: @"Opener" forKey: @"NSExecutable"]
    writeToFile: [app stringByAppendingPathComponent: @"Info-gnustep.plist"]
     atomically: NO];
  [[[NSString stringWithFormat: @"#!/bin/sh\necho \"$@\" >> '%@'\n", log]
    dataUsingEncoding: NSUTF8StringEncoding]
    writeToFile: [app stringByAppendingPathComponent: @"Opener"]
     atomically: NO];
  [mgr changeFileAttributes: [NSDictionary dictionaryWithObject:
    [NSNumber numberWithInt: 0755] forKey: NSFilePosixPermissions]
		     atPath: [app stringByAppendingPathComponent: @"Opener"]];
  first = [dir stringByAppendingPathComponent: @"first.txt"];
  second = [dir stringByAppendingPathComponent: @"second.txt"];
  [[NSData data] writeToFile: first atomically: NO];
  [[NSData data] writeToFile: second atomically: NO];
  urls = [NSArray arrayWithObjects:
    [NSURL fileURLWithPath: first], [NSURL fileURLWithPath: second], nil];

  ok = [ws openURLs: urls
    withAppBundleIdentifier: app
		    options: NSWorkspaceLaunchWithoutActivation
    additionalEventParamDescriptor: nil
	  launchIdentifiers: &identifiers];
  PASS(ok, "the URLs are opened with the application");
  PASS(identifiers == nil, "there are no launch identifiers");

  limit = [NSDate dateWithTimeIntervalSinceNow: 10.0];
  while ([limit timeIntervalSinceNow] > 0)
    {
      opened = [NSString stringWithContentsOfFile: log];
      if ([opened rangeOfString: second].length > 0
	&& [opened rangeOfString: first].length > 0)
	{
	  break;
	}
      [[NSRunLoop currentRunLoop] runUntilDate:
	[NSDate dateWithTimeIntervalSinceNow: 0.1]];
    }
  PASS(opened != nil && [opened rangeOfString: first].length > 0,
    "the application is asked to open the first file");
  PASS(opened != nil && [opened rangeOfString: second].length > 0,
    "the application is asked to open the second file");

  PASS([ws openURLs: urls
    withAppBundleIdentifier: [dir stringByAppendingPathComponent: @"No.app"]
		    options: 0
    additionalEventParamDescriptor: nil
	  launchIdentifiers: NULL] == NO,
    "an application that cannot be found opens nothing");

  [mgr removeFileAtPath: dir handler: nil];

  END_SET("NSWorkspace openURLs:withAppBundleIdentifier:...")

  [pool release];
  return 0;
}
