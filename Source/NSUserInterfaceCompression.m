/* Implementation of class NSSharingServicePickerToolbarItem
   Copyright (C) 2019 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: Tue Apr  7 08:11:46 EDT 2020

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

#import <Foundation/NSObject.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

#import "AppKit/NSUserInterfaceCompression.h"

/* An options object is a set of option identifiers; combining options
 * combines their sets.
 */
@implementation NSUserInterfaceCompressionOptions

/* Answers the identifiers of opts, none for nil or another kind of object.
 */
static NSSet *
identifiersOf(id opts)
{
  if ([opts isKindOfClass: [NSUserInterfaceCompressionOptions class]])
    {
      return ((NSUserInterfaceCompressionOptions *)opts)->_identifiers;
    }
  return [NSSet set];
}

- (instancetype) _initWithIdentifiers: (NSSet *)identifiers
{
  if ((self = [super init]) != nil)
    {
      _identifiers = [identifiers copy];
    }
  return self;
}

- (instancetype) init
{
  return [self _initWithIdentifiers: [NSSet set]];
}

- (instancetype) initWithIdentifier: (NSString *)identifier
{
  if (identifier == nil)
    {
      return [self init];
    }
  return [self _initWithIdentifiers: [NSSet setWithObject: identifier]];
}

- (instancetype) initWithCompressionOptions: (NSSet *)opts
{
  NSMutableSet *identifiers = [NSMutableSet set];
  NSEnumerator *e = [opts objectEnumerator];
  NSUserInterfaceCompressionOptions *o;

  while ((o = [e nextObject]) != nil)
    {
      [identifiers unionSet: identifiersOf(o)];
    }
  return [self _initWithIdentifiers: identifiers];
}

- (void) dealloc
{
  RELEASE(_identifiers);
  [super dealloc];
}

- (BOOL) containsOptions: (NSUserInterfaceCompressionOptions *)opts
{
  return [identifiersOf(opts) isSubsetOfSet: _identifiers];
}

- (BOOL) intersectsOptions: (NSUserInterfaceCompressionOptions *)opts
{
  return [_identifiers intersectsSet: identifiersOf(opts)];
}

- (BOOL) isEmpty
{
  return [_identifiers count] == 0;
}

- (NSUserInterfaceCompressionOptions *) optionsByAddingOptions: (NSUserInterfaceCompressionOptions *)opts
{
  NSMutableSet *identifiers = AUTORELEASE([_identifiers mutableCopy]);

  [identifiers unionSet: identifiersOf(opts)];
  return AUTORELEASE([[[self class] alloc] _initWithIdentifiers: identifiers]);
}

- (NSUserInterfaceCompressionOptions *) optionsByRemovingOptions: (NSUserInterfaceCompressionOptions *)opts
{
  NSMutableSet *identifiers = AUTORELEASE([_identifiers mutableCopy]);

  [identifiers minusSet: identifiersOf(opts)];
  return AUTORELEASE([[[self class] alloc] _initWithIdentifiers: identifiers]);
}

+ (NSUserInterfaceCompressionOptions *) hideImagesOption
{
  return AUTORELEASE([[self alloc]
    initWithIdentifier: @"NSUserInterfaceCompressionOptionHideImages"]);
}

+ (NSUserInterfaceCompressionOptions *) hideTextOption
{
  return AUTORELEASE([[self alloc]
    initWithIdentifier: @"NSUserInterfaceCompressionOptionHideText"]);
}

+ (NSUserInterfaceCompressionOptions *) reduceMetricsOption
{
  return AUTORELEASE([[self alloc]
    initWithIdentifier: @"NSUserInterfaceCompressionOptionReduceMetrics"]);
}

+ (NSUserInterfaceCompressionOptions *) breakEqualWidthsOption
{
  return AUTORELEASE([[self alloc]
    initWithIdentifier: @"NSUserInterfaceCompressionOptionBreakEqualWidths"]);
}

+ (NSUserInterfaceCompressionOptions *) standardOptions
{
  NSSet *all = [NSSet setWithObjects: [self hideImagesOption],
    [self hideTextOption], [self reduceMetricsOption],
    [self breakEqualWidthsOption], nil];

  return AUTORELEASE([[self alloc] initWithCompressionOptions: all]);
}

- (BOOL) isEqual: (id)other
{
  if (other == self)
    {
      return YES;
    }
  if (![other isKindOfClass: [NSUserInterfaceCompressionOptions class]])
    {
      return NO;
    }
  return [_identifiers isEqualToSet: identifiersOf(other)];
}

- (NSUInteger) hash
{
  return [_identifiers hash];
}

/* NSIdentifiers is GNUstep's own key; Cocoa's archive format for this
 * class is not known.
 */
- (void) encodeWithCoder: (NSCoder *)coder
{
  if ([coder allowsKeyedCoding])
    {
      [coder encodeObject: _identifiers forKey: @"NSIdentifiers"];
    }
  else
    {
      [coder encodeObject: _identifiers];
    }
}

- (id) initWithCoder: (NSCoder *)coder
{
  NSSet *identifiers;

  if ([coder allowsKeyedCoding])
    {
      identifiers = [coder decodeObjectForKey: @"NSIdentifiers"];
    }
  else
    {
      identifiers = [coder decodeObject];
    }
  return [self _initWithIdentifiers:
    (identifiers != nil) ? identifiers : [NSSet set]];
}

- (id) copyWithZone: (NSZone *)z
{
  return RETAIN(self);
}

@end

