/* Implementation of class NSTabViewController
   Copyright (C) 2020 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: 23-07-2020

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#import <Foundation/NSArray.h>

#import "AppKit/NSTabViewController.h"
#import "AppKit/NSTabViewItem.h"
#import "AppKit/NSTabView.h"
#import "AppKit/NSToolbarItem.h"

#import "GSFastEnumeration.h"

@implementation NSTabViewController
- (instancetype) initWithNibName: (NSString *)nibNameOrNil
                          bundle: (NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
  if (self != nil)
    {
      _transitionOptions = NSViewControllerTransitionAllowUserInteraction;
      _canPropagateSelectedChildViewControllerTitle = YES;
    }
  return self;
}

- (NSTabViewControllerTabStyle) tabStyle
{
  return _tabStyle;
}

- (void) setTabStyle: (NSTabViewControllerTabStyle)ts
{
  _tabStyle = ts;
}

- (void) loadView
{
  if ([self nibName] != nil)
    {
      [super loadView];
    }
  else
    {
      NSTabView *tv = [[NSTabView alloc]
        initWithFrame: NSMakeRect(0, 0, 250, 200)];

      [self setTabView: tv];
      RELEASE(tv);
    }
}

- (NSTabView *) tabView
{
  return (NSTabView *)[self view];
}

- (void) setTabView: (NSTabView *)tv
{
  [self setView: tv];
  [tv setDelegate: self];
}

- (NSViewControllerTransitionOptions) transitionOptions
{
  return _transitionOptions;
}

- (void) setTransitionOptions: (NSViewControllerTransitionOptions)options
{
  _transitionOptions = options;
}

- (BOOL) canPropagateSelectedChildViewControllerTitle
{
  return _canPropagateSelectedChildViewControllerTitle;
}

- (void) setCanPropagateSelectedChildViewControllerTitle: (BOOL)flag
{
  _canPropagateSelectedChildViewControllerTitle = flag;
}

// Managing tabViewItems...
- (NSArray *) tabViewItems
{
  return [[self tabView] tabViewItems];
}

- (void) setTabViewItems: (NSArray *)items
{
  FOR_IN(NSTabViewItem*, item, items)
    [[self tabView] addTabViewItem: item];
  END_FOR_IN(items);
}

- (NSTabViewItem *) tabViewItemForViewController: (NSViewController *)controller
{
  NSArray *tabViewItems = [[self tabView] tabViewItems];
  FOR_IN(NSTabViewItem*, tvi, tabViewItems)
    if ([tvi viewController] == controller)
      {
        return tvi;
      }
  END_FOR_IN(tabViewItems);
  return nil;
}

- (void) addTabViewItem: (NSTabViewItem *)item
{
  [[self tabView] addTabViewItem: item];
}

- (void) insertTabViewItem: (NSTabViewItem *)item 
                   atIndex: (NSInteger)index
{
  [[self tabView] insertTabViewItem: item atIndex: index];
}

- (void) removeTabViewItem: (NSTabViewItem *)item
{
  [[self tabView] removeTabViewItem: item];
}

- (NSInteger) selectedTabViewItemIndex
{
  NSTabViewItem *selected = [[self tabView] selectedTabViewItem];

  if (selected == nil)
    {
      return -1;
    }
  return [[self tabView] indexOfTabViewItem: selected];
}

/* The selected index changes whenever the tab view selects an item, so
 * observers are told from -tabView:willSelectTabViewItem: and
 * -tabView:didSelectTabViewItem:, not from the setter.
 */
+ (BOOL) automaticallyNotifiesObserversForKey: (NSString *)key
{
  if ([key isEqualToString: @"selectedTabViewItemIndex"])
    {
      return NO;
    }
  return [super automaticallyNotifiesObserversForKey: key];
}

- (void) setSelectedTabViewItemIndex: (NSInteger)idx
{
  [[self tabView] selectTabViewItemAtIndex: idx];
}

// Responding to tabview actions...
- (BOOL)tabView:(NSTabView *)tabView 
  shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  return YES;
}

- (void)tabView:(NSTabView *)tabView
  willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  [self willChangeValueForKey: @"selectedTabViewItemIndex"];
}

/* Subclasses that override this must call super, as on Cocoa. */
- (void)tabView:(NSTabView *)tabView 
  didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  if (_canPropagateSelectedChildViewControllerTitle)
    {
      NSString *title = [tabViewItem label];

      if (title != nil)
        {
          [self setTitle: title];
        }
    }
  [self didChangeValueForKey: @"selectedTabViewItemIndex"];
}

// Responding to toolbar actions...

/* Answers the toolbar item identifiers of the tab view items, one per
 * item and in the same order.  A tab's own identifier is used when it is
 * a non-empty string that no earlier tab uses.  Otherwise, as for the
 * empty identifiers of tabs made with +tabViewItemWithViewController:,
 * one is made from the tab's index.  The items are kept by the tab view,
 * so there are none before it is loaded.
 */
- (NSArray *) _tabViewItemIdentifiers
{
  NSArray *items = [self isViewLoaded] ? [[self tabView] tabViewItems] : nil;
  NSUInteger count = [items count];
  NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity: count];
  NSUInteger i;

  for (i = 0; i < count; i++)
    {
      id identifier = [[items objectAtIndex: i] identifier];

      if (![identifier isKindOfClass: [NSString class]]
        || [identifier length] == 0
        || [identifiers containsObject: identifier])
        {
          identifier = [NSString stringWithFormat: @"GSTabViewItem%lu",
                                 (unsigned long)i];
          while ([identifiers containsObject: identifier])
            {
              identifier = [identifier stringByAppendingString: @"_"];
            }
        }
      [identifiers addObject: identifier];
    }
  return identifiers;
}

/* Selects the tab view item whose toolbar item identifier is the toolbar
 * item's.
 */
- (void) _selectTabViewItemForToolbarItem: (id)sender
{
  NSUInteger idx;

  idx = [[self _tabViewItemIdentifiers] indexOfObject: [sender itemIdentifier]];
  if (idx != NSNotFound)
    {
      [self setSelectedTabViewItemIndex: idx];
    }
}

/** Answers a toolbar item for the tab view item with the toolbar item
 * identifier, with its label, that selects the tab view item.  Answers nil
 * when no tab view item has the identifier.
 */
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier
     willBeInsertedIntoToolbar:(BOOL)flag
{
  NSUInteger idx;
  NSTabViewItem *tvi;
  NSToolbarItem *item;

  idx = [[self _tabViewItemIdentifiers] indexOfObject: itemIdentifier];
  if (idx == NSNotFound)
    {
      return nil;
    }
  tvi = [[self tabView] tabViewItemAtIndex: idx];
  item = AUTORELEASE([[NSToolbarItem alloc]
    initWithItemIdentifier: itemIdentifier]);
  [item setLabel: [tvi label]];
  [item setPaletteLabel: [tvi label]];
  [item setToolTip: [tvi toolTip]];
  [item setTarget: self];
  [item setAction: @selector(_selectTabViewItemForToolbarItem:)];
  return item;
}

/** Answers the identifiers of the tab view items.
 */
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  return [self _tabViewItemIdentifiers];
}

/** Answers the identifiers of the tab view items.
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
  return [self _tabViewItemIdentifiers];
}

/** Answers the identifiers of the tab view items, as each of their
 * toolbar items selects a tab.
 */
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
  return [self _tabViewItemIdentifiers];
}

// NSCoding
- (instancetype) initWithCoder: (NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if ([coder allowsKeyedCoding])
    {
      if ([coder containsValueForKey: @"NSTabView"])
        {
          NSTabView *tv = [coder decodeObjectForKey: @"NSTabView"];
          [self setTabView: tv];

          // Currently we only support the tabs being on the top or the bottom.
          // The rendering code doesn't support anything outside of these two
          // cases.  Here we force the use of the top case, when it is outside
          // of either of the cases we handle... this is temporary.  FIXME
          if ([tv tabViewType] != NSTopTabsBezelBorder &&
              [tv tabViewType] != NSBottomTabsBezelBorder)
            {
              [tv setTabViewType: NSTopTabsBezelBorder];
            }
        }

      if ([coder containsValueForKey: @"NSTabViewControllerCanPropagateSelectedChildViewControllerTitle"])
        {
          BOOL flag = [coder decodeBoolForKey: @"NSTabViewControllerCanPropagateSelectedChildViewControllerTitle"];
          [self setCanPropagateSelectedChildViewControllerTitle: flag];
        }
    }
  else
    {
      BOOL flag;
      [self setTabView: [coder decodeObject]]; // get tabview...
      [coder decodeValueOfObjCType: @encode(BOOL)
                                at: &flag];
      [self setCanPropagateSelectedChildViewControllerTitle: flag];
    }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  [super encodeWithCoder: coder];
  if ([coder allowsKeyedCoding])
    {
      NSTabView *tv = [self tabView];
      [coder encodeObject: tv forKey: @"NSTabView"];
      [coder encodeBool: [self canPropagateSelectedChildViewControllerTitle]
                 forKey: @"NSTabViewControllerCanPropagateSelectedChildViewControllerTitle"];
    }
  else
    {
      BOOL flag = [self canPropagateSelectedChildViewControllerTitle];
      [coder encodeObject: [self tabView]]; // get tabview...
      [coder encodeValueOfObjCType: @encode(BOOL)
                                at: &flag];
    }
}
@end

