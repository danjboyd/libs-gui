/* -setIcon:forFile:options: sets the icon of a directory, which
   -iconForFile: then answers, and removes it when given no image.  A
   plain file has no icon store, so setting its icon fails.  The method used
   to be a stub that answered NO.  The workspace needs the backend, so the
   set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSProcessInfo.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSBitmapImageRep.h>
#include <AppKit/NSImage.h>
#include <AppKit/NSWorkspace.h>

static BOOL
hasRepOfWidth(NSImage *image, NSInteger width)
{
  NSEnumerator *e = [[image representations] objectEnumerator];
  NSImageRep *rep;

  while ((rep = [e nextObject]) != nil)
    {
      if ([rep pixelsWide] == width)
	{
	  return YES;
	}
    }
  return NO;
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSFileManager *mgr = [NSFileManager defaultManager];
  NSWorkspace *ws;
  NSString *dir;
  NSString *file;
  NSBitmapImageRep *rep;
  NSImage *image;

  START_SET("NSWorkspace setIcon:forFile:options:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  ws = [NSWorkspace sharedWorkspace];
  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  [mgr createDirectoryAtPath: dir attributes: nil];
  file = [dir stringByAppendingPathComponent: @"file.txt"];
  [[NSData data] writeToFile: file atomically: NO];

  rep = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes: NULL
		  pixelsWide: 7
		  pixelsHigh: 5
	       bitsPerSample: 8
	     samplesPerPixel: 4
		    hasAlpha: YES
		    isPlanar: NO
	      colorSpaceName: NSDeviceRGBColorSpace
		 bytesPerRow: 0
		bitsPerPixel: 0]);
  image = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(7, 5)]);
  [image addRepresentation: rep];

  PASS([ws setIcon: image forFile: dir options: 0],
    "the icon of a directory is set");
  PASS([mgr fileExistsAtPath: [dir stringByAppendingPathComponent: @".dir.tiff"]],
    "the icon is stored in the directory");
  PASS(hasRepOfWidth([ws iconForFile: dir], 7),
    "iconForFile: answers the directory's icon");

  PASS([ws setIcon: nil forFile: dir options: 0],
    "the icon of a directory is removed");
  PASS(hasRepOfWidth([ws iconForFile: dir], 7) == NO,
    "iconForFile: no longer answers the removed icon");

  PASS([ws setIcon: image forFile: file options: 0] == NO,
    "a plain file's icon cannot be set");
  PASS([ws setIcon: image forFile:
    [dir stringByAppendingPathComponent: @"missing"] options: 0] == NO,
    "a missing file's icon cannot be set");

  [mgr removeFileAtPath: dir handler: nil];

  END_SET("NSWorkspace setIcon:forFile:options:")

  [pool release];
  return 0;
}
