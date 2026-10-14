/* 
   NSColorSpace.h

   The color space class

   Copyright (C) 2007 Free Software Foundation, Inc.

   Author:  H. Nikolaus Schaller <hns@computer.org>
   Date: 2007
   
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

#import <Foundation/NSBundle.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>
#import <AppKit/NSColorSpace.h>
#import "GSGuiPrivate.h"

@implementation NSColorSpace

- (id) _initWithColorSpaceModel: (NSColorSpaceModel)model
{
  if ((self = [super init]))
    {
      _colorSpaceModel = model;
    }
  return self;
}

/* Loads the named ICC profile that ships as a gui library resource under
   ColorSpaces, so a standard colour space can report its profile data. */
- (void) _loadICCProfileNamed: (NSString *)name
{
  NSBundle *bundle = [NSBundle bundleForLibrary: @"gnustep-gui"];
  NSString *path = [bundle pathForResource: name
                                    ofType: @"icc"
                               inDirectory: @"ColorSpaces"];

  if (path != nil)
    {
      ASSIGN(_iccData, [NSData dataWithContentsOfFile: path]);
    }
}

#define COLORSPACE(model) \
  static NSColorSpace *csp = nil;                     \
  if (!csp)                                                           \
    csp = [[self alloc] _initWithColorSpaceModel: model];             \
  return csp;

+ (NSColorSpace *) deviceCMYKColorSpace
{
  COLORSPACE(NSCMYKColorSpaceModel);
}

+ (NSColorSpace *) deviceGrayColorSpace
{
  COLORSPACE(NSGrayColorSpaceModel); 
}

+ (NSColorSpace *) deviceRGBColorSpace
{
  COLORSPACE(NSRGBColorSpaceModel);
}

+ (NSColorSpace *) genericCMYKColorSpace
{
  COLORSPACE(NSCMYKColorSpaceModel);
}

+ (NSColorSpace *) genericGrayColorSpace
{
  COLORSPACE(NSGrayColorSpaceModel);
}

+ (NSColorSpace *) genericRGBColorSpace
{
  static NSColorSpace *csp = nil;

  if (!csp)
    {
      csp = [[self alloc] _initWithColorSpaceModel: NSRGBColorSpaceModel];
      [csp _loadICCProfileNamed: @"sRGB2014"];
    }
  return csp;
}

- (id) initWithColorSyncProfile: (void *)prof
{
  if ((self = [super init]))
    {
      _colorSyncProfile = prof;
      _colorSpaceModel = NSUnknownColorSpaceModel;
    }
  return self;
}

/* Answers the colour space model named by the data colour space field of
 * an ICC profile header, or NSUnknownColorSpaceModel.
 */
static NSColorSpaceModel
modelFromICCProfileData(NSData *iccData)
{
  const unsigned char	*bytes;
  uint32_t		sig;

  /* The header is 128 bytes long, with the 'acsp' signature at offset 36
   * and the data colour space signature at offset 16.
   */
  if ([iccData length] < 128)
    {
      return NSUnknownColorSpaceModel;
    }
  bytes = [iccData bytes];
  if (memcmp(bytes + 36, "acsp", 4) != 0)
    {
      return NSUnknownColorSpaceModel;
    }
  sig = ((uint32_t)bytes[16] << 24) | ((uint32_t)bytes[17] << 16)
    | ((uint32_t)bytes[18] << 8) | (uint32_t)bytes[19];
  switch (sig)
    {
      case 0x47524159:	/* 'GRAY' */
        return NSGrayColorSpaceModel;
      case 0x52474220:	/* 'RGB ' */
        return NSRGBColorSpaceModel;
      case 0x434D594B:	/* 'CMYK' */
        return NSCMYKColorSpaceModel;
      case 0x4C616220:	/* 'Lab ' */
        return NSLABColorSpaceModel;
      default:
        return NSUnknownColorSpaceModel;
    }
}

- (id) initWithICCProfileData: (NSData *)iccData
{
  if ((self = [super init]))
    {
      ASSIGN(_iccData, iccData);
      _colorSpaceModel = modelFromICCProfileData(iccData);
    }
  return self;
}

-(void) dealloc
{
  // FIXME: Free _colorSyncProfile
  TEST_RELEASE(_iccData);
  [super dealloc];
}

- (NSColorSpaceModel) colorSpaceModel
{
  return _colorSpaceModel;
}

- (void *) colorSyncProfile
{
  return _colorSyncProfile;
}

- (NSData *) ICCProfileData
{
  if (!_iccData)
    {
      // FIXME: Try to compute this from _colorSyncProfile
    }
  return _iccData;
}

- (NSString *) localizedName
{
  switch (_colorSpaceModel)
    {
      default:
      case NSUnknownColorSpaceModel: 
        return NSLocalizedString(@"unknown", @"color space");
      case NSGrayColorSpaceModel:
        return NSLocalizedString(@"Grayscale", @"color space");
      case NSRGBColorSpaceModel:
        return NSLocalizedString(@"RGB", @"color space");
      case NSCMYKColorSpaceModel:
        return NSLocalizedString(@"CMYK", @"color space");
      case NSLABColorSpaceModel:
        return NSLocalizedString(@"LAB", @"color space");
      case NSDeviceNColorSpaceModel:
        return NSLocalizedString(@"DeviceN", @"color space");
    }
}

- (int) numberOfColorComponents
{
  switch (_colorSpaceModel)
    {
      default:
      case NSUnknownColorSpaceModel: return 0;
      case NSGrayColorSpaceModel: return 1;
      case NSRGBColorSpaceModel: return 3;
      case NSCMYKColorSpaceModel: return 4;
      case NSLABColorSpaceModel: return 3;	// FIXME
      case NSDeviceNColorSpaceModel: return 3;	// FIXME
    }
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  // FIXME
  if ([coder allowsKeyedCoding])
    {
    }
  else
    {
    }
}

- (id) initWithCoder: (NSCoder *)aDecoder
{
  // FIXME
  if ([aDecoder allowsKeyedCoding])
    {
    }
  else
    {
    }
  return self;
}

@end
