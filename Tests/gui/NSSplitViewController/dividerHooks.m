#import "Testing.h"
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSSplitView.h>
#import <AppKit/NSSplitViewItem.h>
#import <AppKit/NSSplitViewController.h>

/* The split view delegate methods of NSSplitViewController follow the
   items: a subview can collapse when its item can, dividers are shown and
   have no additional effective rect, and -toggleSidebar: collapses and
   expands the sidebar item.  They answered fixed values, and
   -toggleSidebar: only logged.  Needs a window server, so the set skips
   cleanly without one. */

static NSViewController *
aController(void)
{
  NSViewController *vc = AUTORELEASE([[NSViewController alloc] init]);

  [vc setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 120, 100)])];
  return vc;
}

int
main(int argc, const char **argv)
{
  START_SET("NSSplitViewController divider hooks")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSSplitViewController *svc = AUTORELEASE([[NSSplitViewController alloc] init]);
      NSViewController *sideVC = aController();
      NSViewController *detailVC = aController();
      NSSplitViewItem *side = [NSSplitViewItem sidebarWithViewController: sideVC];
      NSSplitViewItem *detail = [NSSplitViewItem splitViewItemWithViewController: detailVC];
      NSSplitView *sv;
      BOOL collapsed;

      [svc addSplitViewItem: side];
      [svc addSplitViewItem: detail];
      sv = [svc splitView];
      [sv setVertical: YES];
      [sv adjustSubviews];

      PASS([svc splitView: sv canCollapseSubview: [sideVC view]] == YES,
        "the sidebar's view can collapse");
      PASS([svc splitView: sv canCollapseSubview: [detailVC view]] == NO,
        "a view whose item cannot collapse cannot");
      PASS([svc splitView: sv shouldCollapseSubview: [detailVC view]
        forDoubleClickOnDividerAtIndex: 0] == NO,
        "a double click does not collapse a view whose item cannot");
      PASS([svc splitView: sv shouldHideDividerAtIndex: 0] == NO,
        "the divider is shown");
      PASS(NSIsEmptyRect([svc splitView: sv
        additionalEffectiveRectOfDividerAtIndex: 0]),
        "the divider has no additional effective rect");

      collapsed = [side isCollapsed];
      [svc toggleSidebar: nil];
      PASS([side isCollapsed] != collapsed, "toggleSidebar: collapses the sidebar");
      [svc toggleSidebar: nil];
      PASS([side isCollapsed] == collapsed, "toggleSidebar: expands it again");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
  NS_ENDHANDLER

  END_SET("NSSplitViewController divider hooks")
  return 0;
}
