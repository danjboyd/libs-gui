/* Implementation of class NSSliderAccessory
   Copyright (C) 2020 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: 31-07-2020

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

#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSString.h>
#import "AppKit/NSSliderAccessory.h"
#import "AppKit/NSImage.h"

/* The kinds of behaviour an NSSliderAccessoryBehavior has.
 */
enum {
  GSSliderAccessoryAutomatic,
  GSSliderAccessoryValueReset,
  GSSliderAccessoryValueStep,
  GSSliderAccessoryTargetAction,
  GSSliderAccessoryHandler
};

@interface NSSliderAccessoryBehavior (Private)
- (instancetype) _initWithKind: (NSInteger)kind;
@end

@implementation NSSliderAccessory

+ (NSSliderAccessory *) accessoryWithImage: (NSImage *)image
{
  NSSliderAccessory *a = AUTORELEASE([[self alloc] init]);

  ASSIGN(a->_image, image);
  return a;
}

- (instancetype) init
{
  if ((self = [super init]) != nil)
    {
      _enabled = YES;
      ASSIGN(_behavior, [NSSliderAccessoryBehavior automaticBehavior]);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_image);
  RELEASE(_behavior);
  [super dealloc];
}

- (NSSliderAccessoryBehavior *) behavior
{
  return _behavior;
}

- (void) setBehavior: (NSSliderAccessoryBehavior *)behavior
{
  ASSIGN(_behavior, behavior);
}

- (BOOL) isEnabled
{
  return _enabled;
}

- (void) setEnabled: (BOOL)flag
{
  _enabled = flag;
}

- (id) copyWithZone: (NSZone *)z
{
  NSSliderAccessory *c = [[[self class] allocWithZone: z] init];

  ASSIGN(c->_image, _image);
  ASSIGN(c->_behavior, _behavior);
  c->_enabled = _enabled;
  return c;
}

/* Cocoa's archive key names for slider accessories are not known, so
 * the keyed archive uses GNUstep's own names.  Unkeyed archives hold
 * nothing, and a decoded accessory has the -init defaults.
 */
- (instancetype) initWithCoder: (NSCoder *)coder
{
  self = [self init];
  if (self != nil && [coder allowsKeyedCoding])
    {
      ASSIGN(_image, [coder decodeObjectForKey: @"GSImage"]);
      if ([coder containsValueForKey: @"GSBehavior"])
        {
          ASSIGN(_behavior, [coder decodeObjectForKey: @"GSBehavior"]);
        }
      if ([coder containsValueForKey: @"GSEnabled"])
        {
          _enabled = [coder decodeBoolForKey: @"GSEnabled"];
        }
    }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  if ([coder allowsKeyedCoding])
    {
      if (_image != nil)
        {
          [coder encodeObject: _image forKey: @"GSImage"];
        }
      if (_behavior != nil)
        {
          [coder encodeObject: _behavior forKey: @"GSBehavior"];
        }
      [coder encodeBool: _enabled forKey: @"GSEnabled"];
    }
}

@end

@implementation NSSliderAccessoryBehavior 

- (instancetype) _initWithKind: (NSInteger)kind
{
  if ((self = [super init]) != nil)
    {
      _kind = kind;
    }
  return self;
}

- (instancetype) init
{
  return [self _initWithKind: GSSliderAccessoryAutomatic];
}

- (void) dealloc
{
  if (_handler != NULL)
    {
      Block_release(_handler);
    }
  [super dealloc];
}

// Initializers
+ (NSSliderAccessoryBehavior *) behaviorWithHandler: (GSSliderAccessoryBehaviorHandler)handler
{
  NSSliderAccessoryBehavior *b;

  b = AUTORELEASE([[self alloc] _initWithKind: GSSliderAccessoryHandler]);
  if (handler != NULL)
    {
      b->_handler = Block_copy(handler);
    }
  return b;
}

+ (NSSliderAccessoryBehavior *) behaviorWithTarget: (id)target action: (SEL)action
{
  NSSliderAccessoryBehavior *b;

  b = AUTORELEASE([[self alloc] _initWithKind: GSSliderAccessoryTargetAction]);
  b->_target = target;
  b->_action = action;
  return b;
}

// Behaviors...
+ (NSSliderAccessoryBehavior *) automaticBehavior
{
  return AUTORELEASE([[self alloc] _initWithKind: GSSliderAccessoryAutomatic]);
}

+ (NSSliderAccessoryBehavior *) valueResetBehavior
{
  return AUTORELEASE([[self alloc] _initWithKind: GSSliderAccessoryValueReset]);
}

+ (NSSliderAccessoryBehavior *) valueStepBehavior
{
  return AUTORELEASE([[self alloc] _initWithKind: GSSliderAccessoryValueStep]);
}

// Handle events...

/** Sends the action to the target, or calls the handler, with the
 * accessory as the argument.  GNUstep sliders do not show accessories
 * yet, so the automatic, value reset and value step behaviours, which
 * act on the slider, do nothing.
 */
- (void) handleAction: (NSSliderAccessory *)sender
{
  switch (_kind)
    {
      case GSSliderAccessoryTargetAction:
        if (_target != nil && _action != NULL)
          {
            [_target performSelector: _action withObject: sender];
          }
        break;
      case GSSliderAccessoryHandler:
        CALL_BLOCK(_handler, sender);
        break;
      default:
        break;
    }
}

/* Behaviours cannot be changed once made, so a copy is the receiver.
 */
- (id) copyWithZone: (NSZone *)z
{
  return RETAIN(self);
}

/* Cocoa's archive key names for slider accessory behaviours are not
 * known, so the keyed archive uses GNUstep's own names.  The kind, the
 * action and, conditionally, the target are kept; a handler block cannot
 * be archived, so a decoded handler behaviour does nothing.  Unkeyed
 * archives hold nothing, and decode as the automatic behaviour.
 */
- (instancetype) initWithCoder: (NSCoder *)coder
{
  self = [self init];
  if (self != nil && [coder allowsKeyedCoding])
    {
      NSString *action = [coder decodeObjectForKey: @"GSAction"];

      _kind = [coder decodeIntegerForKey: @"GSKind"];
      _target = [coder decodeObjectForKey: @"GSTarget"];
      _action = (action == nil) ? NULL : NSSelectorFromString(action);
    }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  if ([coder allowsKeyedCoding])
    {
      [coder encodeInteger: _kind forKey: @"GSKind"];
      if (_target != nil)
        {
          [coder encodeConditionalObject: _target forKey: @"GSTarget"];
        }
      if (_action != NULL)
        {
          [coder encodeObject: NSStringFromSelector(_action)
                       forKey: @"GSAction"];
        }
    }
}
  
@end
