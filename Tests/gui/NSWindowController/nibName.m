#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSBundle.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSWindowController.h>

/* A controller made with -init may name its nib by overriding
   -windowNibName; -windowNibPath and -loadWindow must ask for it. */

@interface NamedWC : NSWindowController
{
@public
  int asked;
}
@end

@implementation NamedWC
- (NSString *) windowNibName
{
  asked++;
  return @"NSWindowControllerNoSuchNib";
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSWindowController nib name")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  {
    NamedWC *wc = AUTORELEASE([[NamedWC alloc] init]);
    NSWindowController *plain = AUTORELEASE([[NSWindowController alloc] init]);
    NSWindowController *byPath = AUTORELEASE([[NSWindowController alloc]
      initWithWindowNibPath: @"/nonexistent/Prefs.gorm" owner: NSApp]);
    NSString *path;
    BOOL raised = NO;
    NSWindow *w = nil;

    path = [wc windowNibPath];
    PASS(wc->asked > 0, "-windowNibPath asks an overridden -windowNibName");
    PASS_EQUAL(path, [[NSBundle mainBundle]
      pathForNibResource: @"NSWindowControllerNoSuchNib"],
      "-windowNibPath looks the overridden name up in the bundle");

    NS_DURING
      w = [wc window];
    NS_HANDLER
      raised = YES;
    NS_ENDHANDLER
    PASS(raised == NO && w == nil,
      "-window without a nib answers nil and does not raise");

    PASS([plain windowNibPath] == nil && [plain windowNibName] == nil,
      "a controller made with -init has no nib");
    raised = NO;
    NS_DURING
      w = [plain window];
    NS_HANDLER
      raised = YES;
    NS_ENDHANDLER
    PASS(raised == NO && w == nil,
      "-window of a controller with no nib answers nil");

    PASS_EQUAL([byPath windowNibPath], @"/nonexistent/Prefs.gorm",
      "a controller made with a path keeps it");
    PASS_EQUAL([byPath windowNibName], @"Prefs",
      "the nib name comes from the path");
  }

  END_SET("NSWindowController nib name")
  return 0;
}
