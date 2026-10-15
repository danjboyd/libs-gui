/*
   NSAnimationContext.h
 
   Created by Gregory John Casamento on Wed Jun 10 2015.
   Copyright (c) 2015 Free Software Foundation, Inc.
 
   Author: Gregory Casamento <greg.casamento@gmail.com>
 
   This file is part of the GNUstep GUI Library.
 
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
 */ 

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSThread.h>
#import <AppKit/NSAnimationContext.h>
#import <AppKit/NSApplication.h>

static NSString *contextStackKey = @"NSAnimationContextStack";

/* The duration Cocoa documents for the context of a grouping.  A context
 * made with -init has no duration.
 */
static const NSTimeInterval defaultGroupingDuration = 0.25;

/* Answers a new context for a grouping, or for the thread outside any
 * grouping.
 */
static NSAnimationContext *
newGroupingContext(Class contextClass)
{
  NSAnimationContext	*context = [contextClass new];

  [context setDuration: defaultGroupingDuration];
  return context;
}

/* Answers the stack of animation contexts of the current thread.  The
 * bottom of the stack is the thread's context outside any grouping, so
 * the stack is never empty.
 */
static NSMutableArray *
contextStack(void)
{
  NSMutableDictionary	*info = [[NSThread currentThread] threadDictionary];
  NSMutableArray	*stack = [info objectForKey: contextStackKey];

  if (stack == nil)
    {
      NSAnimationContext	*context;

      context = newGroupingContext([NSAnimationContext class]);
      stack = [[NSMutableArray alloc] initWithObjects: context, nil];
      [info setObject: stack forKey: contextStackKey];
      RELEASE(stack);
      RELEASE(context);
    }
  return stack;
}

@interface NSAnimationContext (Private)
+ (void) _runCompletionHandler: (id)handler;
@end

@implementation NSAnimationContext : NSObject

/**
 * Begins a new grouping of animation changes, with a new current context
 * for the current thread.  The context has a duration of 0.25 seconds.
 */
+ (void) beginGrouping
{
  NSAnimationContext	*context = newGroupingContext(self);

  [contextStack() addObject: context];
  RELEASE(context);
}

/**
 * Ends the grouping begun by the matching +beginGrouping, and arranges
 * for the completion handler of its context to be called when the
 * animations of the grouping are complete.  GNUstep does not animate the
 * changes made in a grouping, so the handler is called at once when the
 * duration of the context is zero, and otherwise, as when animating, from
 * the current run loop once the duration has passed.  So a handler that
 * begins the next grouping repeats the animation rather than recursing.
 */
+ (void) endGrouping
{
  NSMutableArray			*stack = contextStack();
  NSAnimationContext			*context;
  GSAnimationContextCompletionHandler	handler;

  if ([stack count] < 2)
    {
      NSLog(@"+[NSAnimationContext endGrouping] without +beginGrouping");
      return;
    }
  context = RETAIN([stack lastObject]);
  [stack removeLastObject];
  handler = [context completionHandler];
  if (handler != NULL)
    {
      NSTimeInterval	duration = [context duration];

      if (duration <= 0.0)
	{
	  CALL_NON_NULL_BLOCK_NO_ARGS(handler);
	}
      else
	{
	  id	copy = (id)Block_copy(handler);

	  [self performSelector: @selector(_runCompletionHandler:)
		     withObject: copy
		     afterDelay: duration
			inModes: [NSArray arrayWithObjects:
			  NSDefaultRunLoopMode, NSModalPanelRunLoopMode,
			  NSEventTrackingRunLoopMode, nil]];
	  Block_release((void *)copy);
	}
    }
  RELEASE(context);
}

/* Calls a completion handler deferred by +endGrouping.
 */
+ (void) _runCompletionHandler: (id)handler
{
  GSAnimationContextCompletionHandler	block;

  block = (GSAnimationContextCompletionHandler)handler;
  CALL_NON_NULL_BLOCK_NO_ARGS(block);
}

/**
 * Answers the animation context of the current thread: the context of
 * the innermost grouping, or the thread's context outside any grouping.
 */
+ (NSAnimationContext *) currentContext
{
  return [contextStack() lastObject];
}

/**
 * Runs the changes block with the context of a new grouping, and calls
 * the completion handler when the grouping ends, as +endGrouping does.
 */
+ (void) runAnimationGroup: (GSAnimationContextChanges)changes
         completionHandler: (GSAnimationContextCompletionHandler)completionHandler
{
  NSAnimationContext	*context;
  NSUInteger		depth = [contextStack() count];

  [self beginGrouping];
  context = [self currentContext];
  [context setCompletionHandler: completionHandler];
  NS_DURING
    {
      if (changes != NULL)
	{
	  CALL_NON_NULL_BLOCK(changes, context);
	}
    }
  NS_HANDLER
    {
      NSMutableArray	*stack = contextStack();

      /* End the grouping, and any the changes block left open, without
       * calling a completion handler.
       */
      if ([stack count] > depth)
	{
	  [stack removeObjectsInRange:
	    NSMakeRange(depth, [stack count] - depth)];
	}
      [localException raise];
    }
  NS_ENDHANDLER
  [self endGrouping];
}

- (void) dealloc
{
  if (_completionHandler != NULL)
    {
      Block_release(_completionHandler);
    }
  [super dealloc];
}

// Properties...
- (void) setDuration: (NSTimeInterval)duration
{
  _duration = duration;
}

- (NSTimeInterval) duration
{
  return _duration;
}

- (GSAnimationContextCompletionHandler) completionHandler
{
  return _completionHandler;
}

- (void) setCompletionHandler: (GSAnimationContextCompletionHandler) completionHandler
{
  if (completionHandler != _completionHandler)
    {
      GSAnimationContextCompletionHandler old = _completionHandler;

      /* The handler is a copy property: keep our own copy of the block,
       * as the caller's block may live on the stack or be released.
       */
      _completionHandler = (completionHandler == NULL)
        ? NULL : Block_copy(completionHandler);
      if (old != NULL)
        {
          Block_release(old);
        }
    }
}

- (void *) timingFunction
{
  return NULL;
}

- (void) setTimingFunction: (void *)timingFunction
{
}

@end

