/* A save panel asks its delegate the URL versions of its filename
   questions, as on Cocoa: -panel:shouldEnableURL: for each file it lists
   (a file it answers NO for is listed but cannot be chosen),
   -panel:didChangeToDirectoryURL: when a directory is chosen in the
   browser, and -panel:validateURL:error: when the user confirms a name
   (NO keeps the panel open).  None of them was asked.  The panel needs
   the backend, so the set is skipped without it. */
#include "Testing.h"

#include <AppKit/AppKit.h>

@interface NSSavePanel (URLDelegateTest)
- (NSBrowser *) testBrowser;
- (void) _selectTextInColumn: (int)column;
@end

@implementation NSSavePanel (URLDelegateTest)
- (NSBrowser *) testBrowser
{
  return _browser;
}
@end

@interface URLDelegate : NSObject
{
@public
  NSURL *directoryURL;
  NSURL *validatedURL;
}
@end

@implementation URLDelegate
- (BOOL) panel: (id)sender shouldEnableURL: (NSURL *)url
{
  return ![[url lastPathComponent] isEqual: @"B"];
}
- (void) panel: (id)sender didChangeToDirectoryURL: (NSURL *)url
{
  ASSIGN(directoryURL, url);
}
- (BOOL) panel: (id)sender validateURL: (NSURL *)url error: (NSError **)error
{
  ASSIGN(validatedURL, url);
  return NO;
}
@end

int main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSavePanel *p;
  NSBrowser *browser;
  NSMatrix *m;
  URLDelegate *delegate;
  NSString *testDir;
  NSInteger row;

  START_SET("NSSavePanel URL delegate methods")

  NS_DURING
  {
    [NSApplication sharedApplication];
  }
  NS_HANDLER
  {
    if ([[localException name] isEqualToString: NSInternalInconsistencyException ])
       SKIP("It looks like GNUstep backend is not yet installed")
  }
  NS_ENDHANDLER

  testDir = [[[[NSBundle mainBundle] bundlePath]
    stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
  delegate = AUTORELEASE([URLDelegate new]);
  p = [NSSavePanel savePanel];
  [p setShowsHiddenFiles: NO];
  [p setDelegate: delegate];
  [p setDirectory: [testDir stringByAppendingPathComponent: @"dummy"]];
  browser = [p testBrowser];
  m = [browser matrixInColumn: [browser lastColumn]];
  PASS([m numberOfRows] == 2
    && [[m cellAtRow: 0 column: 0] isEnabled]
    && ![[m cellAtRow: 1 column: 0] isEnabled],
    "a file the delegate does not enable is listed but disabled");

  [p setDirectory: testDir];
  m = [browser matrixInColumn: [browser lastColumn]];
  for (row = 0; row < [m numberOfRows]; row++)
    {
      if ([[[m cellAtRow: row column: 0] stringValue] isEqual: @"dummy"])
	{
	  [m selectCellAtRow: row column: 0];
	}
    }
  [p _selectTextInColumn: [browser lastColumn]];
  PASS([[[delegate->directoryURL path] lastPathComponent] isEqual: @"dummy"],
    "choosing a directory tells the delegate its URL");

  [p setDirectory: [testDir stringByAppendingPathComponent: @"dummy"]];
  [p setNameFieldStringValue: @"new.txt"];
  [p ok: nil];
  PASS([[delegate->validatedURL lastPathComponent] isEqual: @"new.txt"],
    "confirming a name asks the delegate to validate its URL");

  END_SET("NSSavePanel URL delegate methods")

  [pool release];
  return 0;
}
