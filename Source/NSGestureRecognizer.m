/*
   NSGestureRecognizer.m
  
   Abstract base class for monitoring user events

   Copyright (C) 2017 Free Software Foundation, Inc.

   Author: Daniel Ferreira <dtf@stanford.edu>
   Date: 2017

   This file is part of the GNUstep GUI Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSGestureRecognizer.h>
#import <AppKit/NSView.h>

@implementation NSGestureRecognizer
- (id)initWithCoder: (NSCoder *)coder
{
  return nil; 
}

- (void)encodeWithCoder: (NSCoder *)coder
{
  return;
}

- (NSPoint)locationInView:(NSView *)view
{
  /* Recognizers do not track events of their own yet, so locate the
   * application's current event, in the window's base coordinates when
   * there is no view.
   */
  NSEvent *event = [NSApp currentEvent];
  NSPoint location;

  if (event == nil)
    {
      return NSZeroPoint;
    }
  location = [event locationInWindow];
  if (view != nil)
    {
      location = [view convertPoint: location fromView: nil];
    }
  return location;
}
@end

