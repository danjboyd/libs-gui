/*  -*-objc-*-
   NSAttributedString.h

   Categories which add capabilities to NSAttributedString 

   Copyright (C) 1999 Free Software Foundation, Inc.

   Author: Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: July 1999
   
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

#ifndef _GNUstep_H_NSAttributedString
#define _GNUstep_H_NSAttributedString
#import <AppKit/AppKitDefines.h>

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)

#import <Foundation/NSAttributedString.h>
#import <Foundation/NSRange.h>
#import <AppKit/NSFontManager.h>
// for NSWritingDirection
#import <AppKit/NSParagraphStyle.h>
#import <AppKit/NSText.h>

@class NSTextAttachment;
@class NSFileWrapper;
@class NSString;
@class NSDictionary;
@class NSData;
@class NSArray;
@class NSURL;
@class NSError;
@class NSTextBlock;
@class NSTextList;
@class NSTextTable;

/* Global NSString attribute names used in accessing the respective
   property in a text attributes dictionary.  if the key is not in the
   dictionary the default value is assumed.  As in Cocoa they have the
   NSAttributedStringKey type, so Swift imports them as the members of
   NSAttributedString.Key (NSAttributedString.Key.font for
   NSFontAttributeName).  */
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSAttachmentAttributeName
  NS_SWIFT_NAME(attachment);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSBackgroundColorAttributeName
  NS_SWIFT_NAME(backgroundColor);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSBaselineOffsetAttributeName
  NS_SWIFT_NAME(baselineOffset);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSCursorAttributeName
  NS_SWIFT_NAME(cursor);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSExpansionAttributeName
  NS_SWIFT_NAME(expansion);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSFontAttributeName
  NS_SWIFT_NAME(font);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSForegroundColorAttributeName
  NS_SWIFT_NAME(foregroundColor);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSKernAttributeName
  NS_SWIFT_NAME(kern);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSLigatureAttributeName
  NS_SWIFT_NAME(ligature);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSLinkAttributeName
  NS_SWIFT_NAME(link);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSObliquenessAttributeName
  NS_SWIFT_NAME(obliqueness);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSParagraphStyleAttributeName
  NS_SWIFT_NAME(paragraphStyle);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSShadowAttributeName
  NS_SWIFT_NAME(shadow);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSStrikethroughColorAttributeName
  NS_SWIFT_NAME(strikethroughColor);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSStrikethroughStyleAttributeName
  NS_SWIFT_NAME(strikethroughStyle);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSStrokeColorAttributeName
  NS_SWIFT_NAME(strokeColor);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSStrokeWidthAttributeName
  NS_SWIFT_NAME(strokeWidth);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSSuperscriptAttributeName
  NS_SWIFT_NAME(superscript);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSToolTipAttributeName
  NS_SWIFT_NAME(toolTip);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSUnderlineColorAttributeName
  NS_SWIFT_NAME(underlineColor);
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSUnderlineStyleAttributeName
  NS_SWIFT_NAME(underlineStyle);

#if OS_API_VERSION(MAC_OS_X_VERSION_10_8, GS_API_LATEST)
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSTextAlternativesAttributeName
  NS_SWIFT_NAME(textAlternatives);
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_6, GS_API_LATEST)
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSWritingDirectionAttributeName
  NS_SWIFT_NAME(writingDirection);
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSGlyphInfoAttributeName
  NS_SWIFT_NAME(glyphInfo);
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
APPKIT_EXPORT NSString *NSPaperSizeDocumentAttribute;
APPKIT_EXPORT NSString *NSLeftMarginDocumentAttribute;
APPKIT_EXPORT NSString *NSRightMarginDocumentAttribute;
APPKIT_EXPORT NSString *NSTopMarginDocumentAttribute;
APPKIT_EXPORT NSString *NSBottomMarginDocumentAttribute;
APPKIT_EXPORT NSString *NSHyphenationFactorDocumentAttribute;
APPKIT_EXPORT NSString *NSDocumentTypeDocumentAttribute;
APPKIT_EXPORT NSString *NSCharacterEncodingDocumentAttribute;
APPKIT_EXPORT NSString *NSViewSizeDocumentAttribute;
APPKIT_EXPORT NSString *NSViewZoomDocumentAttribute;
APPKIT_EXPORT NSString *NSViewModeDocumentAttribute;
APPKIT_EXPORT NSString *NSBackgroundColorDocumentAttribute;
APPKIT_EXPORT NSString *NSCocoaVersionDocumentAttribute;
APPKIT_EXPORT NSString *NSReadOnlyDocumentAttribute;
APPKIT_EXPORT NSString *NSConvertedDocumentAttribute;
APPKIT_EXPORT NSString *NSDefaultTabIntervalDocumentAttribute;
APPKIT_EXPORT NSString *NSTitleDocumentAttribute;
APPKIT_EXPORT NSString *NSCompanyDocumentAttribute;
APPKIT_EXPORT NSString *NSCopyrightDocumentAttribute;
APPKIT_EXPORT NSString *NSSubjectDocumentAttribute;
APPKIT_EXPORT NSString *NSAuthorDocumentAttribute;
APPKIT_EXPORT NSString *NSKeywordsDocumentAttribute;
APPKIT_EXPORT NSString *NSCommentDocumentAttribute;
APPKIT_EXPORT NSString *NSEditorDocumentAttribute;
APPKIT_EXPORT NSString *NSCreationTimeDocumentAttribute;
APPKIT_EXPORT NSString *NSModificationTimeDocumentAttribute;

// DocumentType values

APPKIT_EXPORT NSString *NSPlainTextDocumentType;
APPKIT_EXPORT NSString *NSRTFTextDocumentType;
APPKIT_EXPORT NSString *NSRTFDTextDocumentType;
APPKIT_EXPORT NSString *NSMacSimpleTextDocumentType;
APPKIT_EXPORT NSString *NSHTMLTextDocumentType;
APPKIT_EXPORT NSString *NSDocFormatTextDocumentType;
APPKIT_EXPORT NSString *NSWordMLTextDocumentType;
APPKIT_EXPORT NSString *NSOfficeOpenXMLTextDocumentType;
APPKIT_EXPORT NSString *NSOpenDocumentTextDocumentType;

// for HTML export

APPKIT_EXPORT NSString *NSExcludedElementsDocumentAttribute;
APPKIT_EXPORT NSString *NSTextEncodingNameDocumentAttribute;
APPKIT_EXPORT NSString *NSPrefixSpacesDocumentAttribute;

// for HTML import

APPKIT_EXPORT NSString *NSBaseURLDocumentOption;
APPKIT_EXPORT NSString *NSCharacterEncodingDocumentOption;
APPKIT_EXPORT NSString *NSDefaultAttributesDocumentOption;
APPKIT_EXPORT NSString *NSDocumentTypeDocumentOption;
APPKIT_EXPORT NSString *NSTextEncodingNameDocumentOption;
APPKIT_EXPORT NSString *NSTextSizeMultiplierDocumentOption;
APPKIT_EXPORT NSString *NSTimeoutDocumentOption;
APPKIT_EXPORT NSString *NSWebPreferencesDocumentOption;
APPKIT_EXPORT NSString *NSWebResourceLoadDelegateDocumentOption;

// special attributes

APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSCharacterShapeAttributeName
  NS_SWIFT_NAME(characterShape);
APPKIT_EXPORT const unsigned NSUnderlineByWordMask;
APPKIT_EXPORT NSAttributedStringKey _Nonnull const NSSpellingStateAttributeName
  NS_SWIFT_NAME(spellingState);
APPKIT_EXPORT const unsigned NSSpellingStateSpellingFlag;
APPKIT_EXPORT const unsigned NSSpellingStateGrammarFlag;

// readFrom... attributes

APPKIT_EXPORT NSString *NSCharacterEncodingDocumentOption;
APPKIT_EXPORT NSString *NSBaseURLDocumentOption;
APPKIT_EXPORT NSString *NSDefaultAttributesDocumentOption;
APPKIT_EXPORT NSString *NSDocumentTypeDocumentOption;

// initWithHTML... attributes

APPKIT_EXPORT NSString *NSTextEncodingNameDocumentOption;
APPKIT_EXPORT NSString *NSTimeoutDocumentOption;
APPKIT_EXPORT NSString *NSWebPreferencesDocumentOption;
APPKIT_EXPORT NSString *NSWebResourceLoadDelegateDocumentOption;
APPKIT_EXPORT NSString *NSTextSizeMultiplierDocumentOption;

// Private Attributes
APPKIT_EXPORT NSString *NSTextInsertionUndoableAttributeName;

/* Currently supported values for NSUnderlineStyleAttributeName.  */
enum _NSUnderlineStyle
{
	NSUnderlineStyleNone   = 0x00,
	NSUnderlineStyleSingle = 0x01,
	NSUnderlineStyleThick  = 0x02,
	NSUnderlineStyleDouble = 0x09
};

enum _NSUnderlinePattern
{
	NSUnderlinePatternSolid      = 0x0000,
	NSUnderlinePatternDot        = 0x0100,
	NSUnderlinePatternDash       = 0x0200,
	NSUnderlinePatternDashDot    = 0x0300,
	NSUnderlinePatternDashDotDot = 0x0400
};
#endif

#if OS_API_VERSION(GS_API_MACOSX, MAC_OS_X_VERSION_10_3)
// Deprecated
enum
{
  GSNoUnderlineStyle = 0,
  NSSingleUnderlineStyle = 1,
	NSUnderlineStrikethroughMask
};
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_11, GS_API_LATEST)
typedef NSInteger NSWritingDirectionFormatType;
enum {
  NSWritingDirectionEmbedding = (0 << 1),
  NSWritingDirectionOverride = (1 << 1)
};
#endif

@interface NSAttributedString (AppKit)
- (BOOL) containsAttachments;
- (GS_GENERIC_CLASS(NSDictionary, NSAttributedStringKey, id)*) fontAttributesInRange: (NSRange)range;
- (GS_GENERIC_CLASS(NSDictionary, NSAttributedStringKey, id)*) rulerAttributesInRange: (NSRange)range;
- (NSUInteger) lineBreakBeforeIndex: (NSUInteger)location
                        withinRange: (NSRange)aRange;
- (NSRange) doubleClickAtIndex: (NSUInteger)location;
- (NSUInteger) nextWordFromIndex: (NSUInteger)location forward: (BOOL)isForward;

- (id) initWithRTF: (NSData*)data documentAttributes: (NSDictionary**)dict;
- (id) initWithRTFD: (NSData*)data documentAttributes: (NSDictionary**)dict;
- (id) initWithPath: (NSString*)path documentAttributes: (NSDictionary**)dict;
- (id) initWithURL: (NSURL*)url documentAttributes: (NSDictionary**)dict;
- (id) initWithRTFDFileWrapper: (NSFileWrapper*)wrapper
  documentAttributes: (NSDictionary**)dict;
- (id) initWithHTML: (NSData*)data documentAttributes: (NSDictionary**)dict;
- (id) initWithHTML: (NSData*)data 
            baseURL: (NSURL*)base
 documentAttributes: (NSDictionary**)dict;

- (NSData*) RTFFromRange: (NSRange)range
      documentAttributes: (NSDictionary*)dict;
- (NSData*) RTFDFromRange: (NSRange)range
       documentAttributes: (NSDictionary*)dict;
- (NSFileWrapper*) RTFDFileWrapperFromRange: (NSRange)range
                         documentAttributes: (NSDictionary*)dict;

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
+ (NSArray *) textFileTypes;
+ (NSArray *) textPasteboardTypes;
+ (NSArray *) textUnfilteredFileTypes;
+ (NSArray *) textUnfilteredPasteboardTypes;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_5, GS_API_LATEST)
+ (NSArray *) textTypes;
+ (NSArray *) textUnfilteredTypes;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
- (NSData *) docFormatFromRange: (NSRange)range
             documentAttributes: (NSDictionary *)dict;
- (id) initWithDocFormat: (NSData *)data
      documentAttributes: (NSDictionary **)dict;
- (id) initWithHTML: (NSData *)data
            options: (NSDictionary *)options
 documentAttributes: (NSDictionary **)dict;

- (NSUInteger) lineBreakByHyphenatingBeforeIndex: (NSUInteger)location
                                     withinRange: (NSRange)aRange;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (NSData *) dataFromRange: (NSRange)range
        documentAttributes: (NSDictionary *)dict
                     error: (NSError **)error;
- (NSFileWrapper *) fileWrapperFromRange: (NSRange)range
                      documentAttributes: (NSDictionary *)dict
                                   error: (NSError **)error;
- (id) initWithData: (NSData *)data
            options: (NSDictionary *)options
 documentAttributes: (NSDictionary **)dict
              error: (NSError **)error;
- (id) initWithURL: (NSURL *)url
           options: (NSDictionary *)options
documentAttributes: (NSDictionary **)dict
             error: (NSError **)error;

- (NSInteger) itemNumberInTextList: (NSTextList *)list
                           atIndex: (NSUInteger)location;
- (NSRange) rangeOfTextBlock: (NSTextBlock *)block
                     atIndex: (NSUInteger)location;
- (NSRange) rangeOfTextList: (NSTextList *)list
                    atIndex: (NSUInteger)location;
- (NSRange) rangeOfTextTable: (NSTextTable *)table
                     atIndex: (NSUInteger)location;
#endif
@end

@interface NSMutableAttributedString (AppKit)
- (void) superscriptRange: (NSRange)range;
- (void) subscriptRange: (NSRange)range;
- (void) unscriptRange: (NSRange)range;
- (void) applyFontTraits: (NSFontTraitMask)traitMask range: (NSRange)range;
- (void) setAlignment: (NSTextAlignment)alignment range: (NSRange)range;

- (void) fixAttributesInRange: (NSRange)range;
- (void) fixFontAttributeInRange: (NSRange)range;
- (void) fixParagraphStyleAttributeInRange: (NSRange)range;
- (void) fixAttachmentAttributeInRange: (NSRange)range;

- (void) updateAttachmentsFromPath: (NSString *)path;

- (BOOL) readFromURL: (NSURL *)url
	     options: (NSDictionary *)options
  documentAttributes: (NSDictionary**)documentAttributes;
#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
- (BOOL) readFromData: (NSData *)data
              options: (NSDictionary *)options
   documentAttributes: (NSDictionary **)documentAttributes;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (BOOL) readFromData: (NSData *)data
              options: (NSDictionary *)options
   documentAttributes: (NSDictionary **)documentAttributes
                error: (NSError **)error;
- (BOOL) readFromURL: (NSURL *)url
             options: (NSDictionary *)options
  documentAttributes: (NSDictionary **)documentAttributes
               error: (NSError **)error;

- (void) setBaseWritingDirection: (NSWritingDirection)writingDirection
                           range: (NSRange)range;
#endif
@end

#endif

#endif

