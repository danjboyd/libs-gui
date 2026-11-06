/* Decoding a font on a system with no fonts must not crash.  An app's model
 * file holds fonts, in cells and elsewhere, and is decoded at launch.
 *
 * This program writes its archive in a child, with the system's fonts, and
 * decodes it after pointing fontconfig at an empty directory.
 */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
  START_SET("decoding a font without any font")
  NSFileManager	*fm = [NSFileManager defaultManager];
  NSString	*dir;
  NSString	*empty;
  NSString	*config;
  NSString	*archive;
  NSData	*data;
  NSData	*data2;
  id		result = nil;
  id		result2 = nil;
  BOOL		raised = NO;

  if (argc == 2)
    {
      /* The child: a role font and an explicit one. */
      NS_DURING
	{
	  NSApplication	*app = [NSApplication sharedApplication];
	  NSFont	*role = [NSFont userFontOfSize: 12];
	  NSFont	*named = [NSFont fontWithName: [role fontName] size: 12];

	  if (app != nil && role != nil && named != nil)
	    {
	      NSString	*path = [NSString stringWithUTF8String: argv[1]];

	      [NSArchiver archiveRootObject: role toFile: path];
	      [NSArchiver archiveRootObject: named
				     toFile: [path stringByAppendingString: @"2"]];
	    }
	}
      NS_HANDLER
      NS_ENDHANDLER
      exit(0);
    }

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  empty = [dir stringByAppendingPathComponent: @"none"];
  [fm createDirectoryAtPath: empty withIntermediateDirectories: YES
		 attributes: nil error: NULL];
  archive = [dir stringByAppendingPathComponent: @"fonts.archive"];
  system([[NSString stringWithFormat: @"'%s' '%@' >/dev/null 2>&1",
    argv[0], archive] UTF8String]);
  data = [NSData dataWithContentsOfFile: archive];
  data2 = [NSData dataWithContentsOfFile:
    [archive stringByAppendingString: @"2"]];
  if (nil == data || nil == data2)
    {
      [fm removeItemAtPath: dir error: NULL];
      SKIP("no display, backend or font to write the archive with")
    }

  config = [dir stringByAppendingPathComponent: @"fonts.conf"];
  [[NSString stringWithFormat:
    @"<?xml version=\"1.0\"?>\n<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n"
    @"<fontconfig><dir>%@</dir><cachedir>%@/cache</cachedir></fontconfig>\n",
    empty, dir] writeToFile: config atomically: NO
		   encoding: NSUTF8StringEncoding error: NULL];
  setenv("FONTCONFIG_FILE", [config fileSystemRepresentation], 1);

  NS_DURING
    {
      [NSApplication sharedApplication];
      if ([NSFont userFontOfSize: 12] != nil)
	{
	  /* Another backend, not using fontconfig: nothing to check. */
	  [fm removeItemAtPath: dir error: NULL];
	  SKIP("fonts are still found with fontconfig's directory empty")
	}
      result = [NSUnarchiver unarchiveObjectWithData: data];
      result2 = [NSUnarchiver unarchiveObjectWithData: data2];
    }
  NS_HANDLER
    raised = YES;
  NS_ENDHANDLER
  PASS(NO == raised, "decoding raises nothing")
  PASS(nil == result, "a font in a role decodes to nil")
  PASS(nil == result2, "and so does an explicit one")
  [fm removeItemAtPath: dir error: NULL];
  END_SET("decoding a font without any font")
  return 0;
}
