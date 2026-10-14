/* The interior background style of a row view follows its selection: an
 * emphasized selected row is drawn on an emphasized background, any other
 * row on a normal one.  The style was never computed, so it was always
 * normal.
 */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCell.h>
#include <AppKit/NSTableRowView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTableRowView *view;

  START_SET("NSTableRowView interiorBackgroundStyle")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  view = AUTORELEASE([[NSTableRowView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 20)]);
  [view setEmphasized: YES];
  PASS([view interiorBackgroundStyle] == NSBackgroundStyleNormal,
    "an unselected row has a normal interior");
  [view setSelected: YES];
  PASS([view interiorBackgroundStyle] == NSBackgroundStyleEmphasized,
    "an emphasized selected row has an emphasized interior");
  [view setEmphasized: NO];
  PASS([view interiorBackgroundStyle] == NSBackgroundStyleNormal,
    "a selected row that is not emphasized has a normal interior");

  END_SET("NSTableRowView interiorBackgroundStyle")

  [pool release];
  return 0;
}
