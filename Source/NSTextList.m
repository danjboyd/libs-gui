/*
   NSTextList.m

   Copyright (C) 2008 Free Software Foundation, Inc.

   Author:  H. Nikolaus Schaller
   Date: 2007
   Author:  Fred Kiefer <fredkiefer@gmx.de>
   Date: January 2008
   
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

#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>

#import "AppKit/NSTextList.h"


/* Answers item as a roman numeral, in upper case or lower case, or as a
 * decimal number when it is out of the range roman numerals cover.
 */
static NSString *
GSRomanNumeral(int item, BOOL upper)
{
  static const int values[] = {
    1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1
  };
  static const char *upperDigits[] = {
    "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"
  };
  static const char *lowerDigits[] = {
    "m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i"
  };
  NSMutableString *r;
  unsigned i;

  if (item < 1 || item > 3999)
    {
      return [NSString stringWithFormat: @"%d", item];
    }
  r = [NSMutableString string];
  for (i = 0; i < sizeof(values) / sizeof(values[0]); i++)
    {
      while (item >= values[i])
        {
          [r appendString: [NSString stringWithUTF8String:
            (upper ? upperDigits[i] : lowerDigits[i])]];
          item -= values[i];
        }
    }
  return r;
}

@implementation NSTextList

- (id) initWithMarkerFormat: (NSString *)format 
                    options: (unsigned int)mask
{
  ASSIGN(_markerFormat, format); 
  _listOptions = mask;
  _startingItemNumber = 1;

  return self;
}

- (void) dealloc
{
  RELEASE(_markerFormat);
  [super dealloc];
}

- (unsigned int) listOptions
{
  return _listOptions;
}

- (NSString *) markerFormat
{
  return _markerFormat;
}

- (NSString *) markerForItemNumber: (int)item
{
  NSMutableString *s = [_markerFormat mutableCopy];
  unichar box = 0x25AB;
  unichar check = 0x2713;
  unichar circle = 0x25E6;
  unichar diamond = 0x25C6;
  unichar disc = 0x2022;
  unichar hyphen = 0x2043;
  unichar square = 0x25AA;

  // FIXME: Needs optimisation
  // FIXME: Take _startingItemNumber into account.
  [s replaceOccurrencesOfString: @"{box}" 
     withString: [NSString stringWithCharacters: &box length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{check}" 
     withString: [NSString stringWithCharacters: &check length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{circle}" 
     withString: [NSString stringWithCharacters: &circle length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{diamond}" 
     withString: [NSString stringWithCharacters: &diamond length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{disc}" 
     withString: [NSString stringWithCharacters: &disc length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{hyphen}" 
     withString: [NSString stringWithCharacters: &hyphen length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{square}" 
     withString: [NSString stringWithCharacters: &square length: 1] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{decimal}" 
     withString: [NSString stringWithFormat: @"%d", item] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{lower-roman}" 
     withString: GSRomanNumeral(item, NO)
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{upper-roman}" 
     withString: GSRomanNumeral(item, YES)
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{octal}" 
     withString: [NSString stringWithFormat: @"%o", item] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{lower-hexadecimal}" 
     withString: [NSString stringWithFormat: @"%x", item] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{upper-hexadecimal}" 
     withString: [NSString stringWithFormat: @"%X", item] 
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{lower-alpha}" 
     withString: [NSString stringWithFormat: @"%c", item - 1 + 'a']
     options: 0 
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{lower-latin}" 
     withString: [NSString stringWithFormat: @"%c", item - 1 + 'a']
     options: 0
     range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{upper-alpha}"
     withString: [NSString stringWithFormat: @"%c", item - 1 + 'A']
     options: 0 range: NSMakeRange(0, [s length])];
  [s replaceOccurrencesOfString: @"{upper-latin}"
     withString: [NSString stringWithFormat: @"%c", item - 1 + 'A']
     options: 0
     range: NSMakeRange(0, [s length])];

  return AUTORELEASE(s);
}

- (id) copyWithZone: (NSZone*)zone
{
  NSTextList *l = (NSTextList*)NSCopyObject(self, 0, zone);

  _markerFormat = TEST_RETAIN(_markerFormat);

  return l;
}

- (void) encodeWithCoder: (NSCoder*)aCoder
{
  if ([aCoder allowsKeyedCoding])
    {
      [aCoder encodeObject: _markerFormat
                    forKey: @"NSMarkerFormat"];
      [aCoder encodeInt: _listOptions
                 forKey: @"NSOptions"];
      // FIXME: encode _startingItemNumber correctly.
    }
  else
    {
    }
}

- (id) initWithCoder: (NSCoder*)aDecoder
{
  if ([aDecoder allowsKeyedCoding])
    {
      ASSIGN(_markerFormat, [aDecoder decodeObjectForKey: @"NSMarkerFormat"]);
      _listOptions = [aDecoder decodeIntForKey: @"NSOptions"];
     // FIXME: decode _startingItemNumber correctly.
    }
  else
    {
    }
  return self;
}

- (NSInteger) startingItemNumber
{
  return _startingItemNumber;
}

- (void) setStartingItemNumber: (NSInteger)start
{
  _startingItemNumber = start;
}

@end
