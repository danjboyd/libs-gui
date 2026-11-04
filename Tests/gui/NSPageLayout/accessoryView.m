/* -[NSPageLayout setAccessoryView:] shows the view in the panel, below what is
   already there, and taking it out leaves the panel as it was. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSPageLayout.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>

int
main(int argc, char **argv)
{
  START_SET("NSPageLayout accessory view")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSPageLayout *layout = [NSPageLayout pageLayout];
      NSView *content = [layout contentView];
      NSSize size = [content frame].size;
      NSRect first = [[[content subviews] objectAtIndex: 0] frame];
      NSView *view;
      NSView *other;
      NSEnumerator *e;
      NSView *v;
      BOOL clear = YES;

      view = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 120, 50)]);
      other = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 30)]);

      [layout setAccessoryView: view];
      PASS([layout accessoryView] == view, "the accessory view round-trips");
      PASS([view window] == (NSWindow*)layout, "the view is in the panel");
      PASS([content frame].size.height >= size.height + 50,
        "the panel grows to make room");
      PASS(NSContainsRect([content bounds], [view frame]),
        "the view is inside the panel");
      e = [[content subviews] objectEnumerator];
      while ((v = [e nextObject]) != nil)
        {
          if (v != view && NSIntersectsRect([v frame], [view frame]))
            {
              clear = NO;
            }
        }
      PASS(clear, "the view covers nothing else in the panel");

      [layout setAccessoryView: other];
      PASS([view window] == nil && [other window] == (NSWindow*)layout,
        "a new view replaces the old one");

      [layout setAccessoryView: nil];
      PASS([layout accessoryView] == nil && [other window] == nil,
        "the view can be taken out");
      PASS(NSEqualSizes([content frame].size, size),
        "the panel goes back to its size");
      PASS(NSEqualRects([[[content subviews] objectAtIndex: 0] frame], first),
        "what was in the panel goes back to its place");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSPageLayout accessory view")

  return 0;
}
