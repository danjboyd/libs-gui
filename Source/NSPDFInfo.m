/* Implementation of class NSPDFInfo
   Copyright (C) 2019 Free Software Foundation, Inc.
   
   By: Gregory Casamento <greg.casamento@gmail.com>
   Date: Sat Nov 16 21:20:46 EST 2019

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
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
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSURL.h>
#import <AppKit/NSPDFInfo.h>

@implementation NSPDFInfo

- (instancetype) init
{
  self = [super init];
  if (self != nil)
    {
      _attributes = [[NSMutableDictionary alloc] init];
      _tagNames = [[NSArray alloc] init];
      _fileExtensionHidden = YES;
      _paperSize = [[NSPrintInfo sharedPrintInfo] paperSize];
    }
  return self;
}

/* The keyed archive names are GNUstep's own.
 */
- (instancetype) initWithCoder: (NSCoder *)coder
{
  self = [self init];
  if (self == nil)
    {
      return nil;
    }

  if ([coder allowsKeyedCoding])
    {
      NSArray *tagNames = [coder decodeObjectForKey: @"GSTagNames"];
      NSDictionary *attributes = [coder decodeObjectForKey: @"GSAttributes"];

      ASSIGN(_url, [coder decodeObjectForKey: @"GSURL"]);
      if (tagNames != nil)
        {
          ASSIGNCOPY(_tagNames, tagNames);
        }
      if (attributes != nil)
        {
          [_attributes setDictionary: attributes];
        }
      if ([coder containsValueForKey: @"GSFileExtensionHidden"])
        {
          _fileExtensionHidden =
            [coder decodeBoolForKey: @"GSFileExtensionHidden"];
        }
      _orientation = (NSPaperOrientation)
        [coder decodeIntegerForKey: @"GSOrientation"];
      if ([coder containsValueForKey: @"GSPaperSize"])
        {
          _paperSize = [coder decodeSizeForKey: @"GSPaperSize"];
        }
    }
  else
    {
      NSArray *tagNames;
      NSDictionary *attributes;
      NSInteger orientation;

      ASSIGN(_url, [coder decodeObject]);
      tagNames = [coder decodeObject];
      if (tagNames != nil)
        {
          ASSIGNCOPY(_tagNames, tagNames);
        }
      attributes = [coder decodeObject];
      if (attributes != nil)
        {
          [_attributes setDictionary: attributes];
        }
      [coder decodeValueOfObjCType: @encode(BOOL) at: &_fileExtensionHidden];
      [coder decodeValueOfObjCType: @encode(NSInteger) at: &orientation];
      _orientation = (NSPaperOrientation)orientation;
      _paperSize = [coder decodeSize];
    }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  if ([coder allowsKeyedCoding])
    {
      if (_url != nil)
        {
          [coder encodeObject: _url forKey: @"GSURL"];
        }
      [coder encodeObject: _tagNames forKey: @"GSTagNames"];
      [coder encodeObject: _attributes forKey: @"GSAttributes"];
      [coder encodeBool: _fileExtensionHidden forKey: @"GSFileExtensionHidden"];
      [coder encodeInteger: _orientation forKey: @"GSOrientation"];
      [coder encodeSize: _paperSize forKey: @"GSPaperSize"];
    }
  else
    {
      NSInteger orientation = _orientation;

      [coder encodeObject: _url];
      [coder encodeObject: _tagNames];
      [coder encodeObject: _attributes];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &_fileExtensionHidden];
      [coder encodeValueOfObjCType: @encode(NSInteger) at: &orientation];
      [coder encodeSize: _paperSize];
    }
}

- (void) dealloc
{
  RELEASE(_url);
  RELEASE(_tagNames);
  RELEASE(_attributes);
  [super dealloc];
}

- (instancetype) copyWithZone: (NSZone *)zone
{
  NSPDFInfo *copy = [[[self class] allocWithZone: zone] init];

  if (copy != nil)
    {
      RELEASE(copy->_url);
      copy->_url = [_url copyWithZone: zone];
      copy->_fileExtensionHidden = _fileExtensionHidden;
      RELEASE(copy->_tagNames);
      copy->_tagNames = [_tagNames copyWithZone: zone];
      copy->_paperSize = _paperSize;
      RELEASE(copy->_attributes);
      copy->_attributes = [_attributes mutableCopyWithZone: zone];
      copy->_orientation = _orientation;
    }

  return copy;
}

- (NSURL *) URL
{
  return _url;
}

- (BOOL) isFileExtensionHidden
{
  return _fileExtensionHidden;
}

- (void) setFileExtensionHidden: (BOOL)flag
{
  _fileExtensionHidden = flag;
}
  
- (NSArray *) tagNames
{
  return _tagNames;
}

- (NSPaperOrientation) orientation
{
  return _orientation;
}

- (void) setOrientation: (NSPaperOrientation)orientation
{
  _orientation = orientation;
}

- (NSSize) paperSize
{
  return _paperSize;
}

- (void) setPaperSize: (NSSize)size
{
  _paperSize = size;
}

- (NSMutableDictionary *) attributes
{
  return _attributes;
}

@end

