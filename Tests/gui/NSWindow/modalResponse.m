/* NSModalResponse is an NSInteger, and its constants keep their values
   and work as case labels, whether they are declared as static constants
   of the type (for Clang, so Swift sees NSApplication.ModalResponse) or
   as an enumeration.  Needs no backend. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <AppKit/NSWindow.h>

static NSString *
name(NSModalResponse response)
{
  switch (response)
    {
      case NSModalResponseOK:		return @"NSModalResponseOK";
      case NSModalResponseCancel:	return @"NSModalResponseCancel";
      case NSModalResponseStop:		return @"NSModalResponseStop";
      case NSAlertFirstButtonReturn:	return @"NSAlertFirstButtonReturn";
      default:				return nil;
    }
}

int
main(int argc, const char **argv)
{
  START_SET("NSWindow modal response")

  PASS(sizeof(NSModalResponse) == sizeof(NSInteger),
    "the response type is an NSInteger");
  PASS(NSModalResponseOK == 1 && NSModalResponseCancel == 0
    && NSModalResponseStop == -1000 && NSModalResponseAbort == -1001
    && NSModalResponseContinue == -1002,
    "the modal responses keep their values");
  PASS(NSAlertFirstButtonReturn == 1000 && NSAlertSecondButtonReturn == 1001
    && NSAlertThirdButtonReturn == 1002,
    "the alert button returns keep their values");
  PASS_EQUAL(([NSArray arrayWithObjects: name(NSModalResponseOK),
    name(NSModalResponseStop), name(NSAlertFirstButtonReturn), nil]),
    ([NSArray arrayWithObjects: @"NSModalResponseOK",
    @"NSModalResponseStop", @"NSAlertFirstButtonReturn", nil]),
    "the responses work as case labels");

  END_SET("NSWindow modal response")
  return 0;
}
