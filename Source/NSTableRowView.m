/* Implementation of class NSTableRowView
   Copyright (C) 2022 Free Software Foundation, Inc.

   By: Gregory John Casamento
   Date: 03-09-2022

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
#import "AppKit/NSColor.h"
#import "AppKit/NSGraphics.h"
#import "AppKit/NSTableRowView.h"
#import "AppKit/NSTableView.h"

@implementation NSTableRowView

- (void) dealloc
{
  RELEASE(_backgroundColor);
  DEALLOC
}

- (BOOL) isEmphasized
{
  return _emphasized;
}

- (void) setEmphasized: (BOOL)flag
{
  _emphasized = flag;
}

- (NSBackgroundStyle) interiorBackgroundStyle
{
  // Content on an emphasized selection is drawn as on a dark background.
  if (_selected && _emphasized)
    {
      return NSBackgroundStyleEmphasized;
    }
  return NSBackgroundStyleNormal;
}

- (BOOL) isFloating
{
  return _floating;
}

- (void) setFloating: (BOOL)flag
{
  _floating = flag;
}

- (BOOL) isSelected
{
  return _selected;
}

- (void) setSelected: (BOOL)flag
{
  _selected = flag;
}

- (NSTableViewSelectionHighlightStyle) selectionHighlightStyle
{
  return _selectionHighlightStyle;
}

- (void) setSelectionHighlightStyle: (NSTableViewSelectionHighlightStyle) selectionHighlightStyle
{
  _selectionHighlightStyle = selectionHighlightStyle;
}

- (NSTableViewDraggingDestinationFeedbackStyle) draggingDestinationFeedbackStyle
{
  return _draggingDestinationFeedbackStyle;
}

- (void) setDraggingDestinationFeedbackStyle: (NSTableViewDraggingDestinationFeedbackStyle) draggingDestinationFeedbackStyle
{
  _draggingDestinationFeedbackStyle = draggingDestinationFeedbackStyle;
}

- (CGFloat) indentationForDropOperation
{
  return _indentationForDropOperation;
}

- (void) setIndentationForDropOperation: (CGFloat)indentationForDropOperation
{
  _indentationForDropOperation = indentationForDropOperation;
}

- (BOOL) isTargetForDropOperation
{
  return _targetForDropOperation;
}

- (void) setTargetForDropOperation: (BOOL)flag
{
  _targetForDropOperation = flag;
}

- (BOOL) isGroupRowStyle
{
  return _groupRowStyle;
}

- (void) setGroupRowStyle: (BOOL)flag
{
  _groupRowStyle = flag;
}

/* Answers the table view holding the row view, if any.  */
- (NSTableView *) _tableView
{
  NSView *sv = [self superview];

  if ([sv isKindOfClass: [NSTableView class]])
    {
      return (NSTableView *)sv;
    }
  return nil;
}

- (NSInteger) numberOfColumns
{
  NSTableView *tv = [self _tableView];

  /* A row view on its own holds one view per column.  */
  if (tv == nil)
    {
      return [[self subviews] count];
    }
  return [tv numberOfColumns];
}

- (NSColor *) backgroundColor
{
  return _backgroundColor;
}

- (void) setBackgroundColor: (NSColor *)color
{
  ASSIGN(_backgroundColor, color);
}

- (void) drawBackgroundInRect: (NSRect)dirtyRect
{
  if (_backgroundColor != nil)
    {
      [_backgroundColor set];
      NSRectFill(NSIntersectionRect(dirtyRect, [self bounds]));
    }
}

- (void) drawDraggingDestinationFeedbackInRect: (NSRect)dirtyRect
{
  if (_targetForDropOperation)
    {
      [[NSColor selectedControlColor] set];
      NSFrameRectWithWidth([self bounds], 2.0);
    }
}

- (void) drawSelectionInRect: (NSRect)dirtyRect
{
  if (_selected
    && _selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone)
    {
      if (_emphasized)
	{
	  [[NSColor alternateSelectedControlColor] set];
	}
      else
	{
	  [[NSColor secondarySelectedControlColor] set];
	}
      NSRectFill(NSIntersectionRect(dirtyRect, [self bounds]));
    }
}

- (void) drawSeparatorInRect: (NSRect)dirtyRect
{
  NSRect bounds = [self bounds];
  NSRect line = bounds;

  // A one point line along the bottom edge of the row.
  line.size.height = 1.0;
  if ([self isFlipped])
    {
      line.origin.y = NSMaxY(bounds) - 1.0;
    }
  [[NSColor gridColor] set];
  NSRectFill(NSIntersectionRect(dirtyRect, line));
}

- (id) viewAtColumn: (NSInteger)column
{
  NSTableView *tv = [self _tableView];
  NSRect frame = [self frame];
  NSInteger row;

  if (tv == nil)
    {
      NSArray *subviews = [self subviews];

      if (column < 0 || column >= (NSInteger)[subviews count])
	{
	  return nil;
	}
      return [subviews objectAtIndex: column];
    }

  /* A table only places the views of the visible columns in the row, so
   * ask the table for the view of the column in this row.
   */
  row = [tv rowAtPoint: NSMakePoint(NSMidX(frame), NSMidY(frame))];
  if (row < 0 || column < 0 || column >= [tv numberOfColumns])
    {
      return nil;
    }
  return [tv viewAtColumn: column row: row makeIfNecessary: NO];
}

- (BOOL) isNextRowSelected
{
  return _nextRowSelected;
}

- (void) setNextRowSelected: (BOOL)flag
{
  _nextRowSelected = flag;
}

- (BOOL) isPreviousRowSelected
{
  return _previousRowSelected;
}

- (void) setPreviousRowSelected: (BOOL)flag
{
  _previousRowSelected = flag;
}

@end
