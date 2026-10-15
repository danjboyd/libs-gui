/* NSApplicationTerminateReply is an enumeration of NSUInteger, as in
   Cocoa, and keeps the values that let an older delegate answer
   -applicationShouldTerminate: with a BOOL.  Needs no backend. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>

static NSString *
name(NSApplicationTerminateReply reply)
{
  switch (reply)
    {
      case NSTerminateCancel:	return @"NSTerminateCancel";
      case NSTerminateNow:	return @"NSTerminateNow";
      case NSTerminateLater:	return @"NSTerminateLater";
    }
  return nil;
}

int
main(int argc, const char **argv)
{
  START_SET("NSApplication terminate reply")

  PASS(sizeof(NSApplicationTerminateReply) == sizeof(NSUInteger),
    "the reply type has the size of NSUInteger");
  PASS(NSTerminateCancel == NO && NSTerminateNow == YES
    && NSTerminateLater == 2, "the replies keep their values");
  PASS_EQUAL(([NSArray arrayWithObjects: name(NSTerminateCancel),
    name(NSTerminateNow), name(NSTerminateLater), nil]),
    ([NSArray arrayWithObjects: @"NSTerminateCancel", @"NSTerminateNow",
    @"NSTerminateLater", nil]),
    "the replies work as case labels");

  END_SET("NSApplication terminate reply")
  return 0;
}
