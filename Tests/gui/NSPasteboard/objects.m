/* -[NSPasteboard writeObjects:] writes the types and values that
   NSPasteboardWriting objects give, asking each for its writing options,
   and -readObjectsForClasses:options: makes an NSPasteboardReading object
   from a type the pasteboard holds, in the form the class asks for with
   +readingOptionsForType:pasteboard:.  -writeObjects: was a stub that
   answered NO, and there was no -readObjectsForClasses:options:, so neither
   writingOptionsForType:pasteboard: nor readingOptionsForType:pasteboard:
   was ever asked.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>

#include <AppKit/NSPasteboard.h>

/* NSPasteboard.h does not declare these yet. */
@interface NSPasteboard (Objects)
- (NSInteger) clearContents;
- (BOOL) writeObjects: (NSArray*)objects;
- (NSArray*) readObjectsForClasses: (NSArray*)classArray
			   options: (NSDictionary*)options;
@end

static NSString *textType = @"org.gnustep.test.text";
static NSString *listType = @"org.gnustep.test.list";

@interface Writer : NSObject <NSPasteboardWriting>
{
@public
  NSUInteger optionsAsked;
}
@end
@implementation Writer
- (NSArray *) writableTypesForPasteboard: (NSPasteboard *)pasteboard
{
  return [NSArray arrayWithObjects: textType, listType, nil];
}
- (NSPasteboardWritingOptions) writingOptionsForType: (NSString *)type
					  pasteboard: (NSPasteboard *)pb
{
  optionsAsked++;
  return 0;
}
- (id) pasteboardPropertyListForType: (NSString *)type
{
  if ([type isEqual: textType])
    {
      return @"some text";
    }
  return [NSDictionary dictionaryWithObject: @"value" forKey: @"key"];
}
@end

static NSUInteger readingOptionsAsked = 0;

@interface Reader : NSObject <NSPasteboardReading>
{
@public
  id value;
  NSString *type;
}
@end
@implementation Reader
+ (NSArray *) readableTypesForPasteboard: (NSPasteboard *)pasteboard
{
  return [NSArray arrayWithObjects: @"org.gnustep.test.missing", listType, nil];
}
+ (NSPasteboardReadingOptions) readingOptionsForType: (NSString *)t
					  pasteboard: (NSPasteboard *)pb
{
  readingOptionsAsked++;
  return NSPasteboardReadingAsPropertyList;
}
- (id) initWithPasteboardPropertyList: (id)propertyList ofType: (NSString *)t
{
  if ((self = [super init]) != nil)
    {
      value = RETAIN(propertyList);
      type = [t copy];
    }
  return self;
}
- (void) dealloc
{
  RELEASE(value);
  RELEASE(type);
  [super dealloc];
}
@end

@interface TextReader : Reader
@end
@implementation TextReader
+ (NSArray *) readableTypesForPasteboard: (NSPasteboard *)pasteboard
{
  return [NSArray arrayWithObject: textType];
}
+ (NSPasteboardReadingOptions) readingOptionsForType: (NSString *)t
					  pasteboard: (NSPasteboard *)pb
{
  return NSPasteboardReadingAsString;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPasteboard *pb = nil;
  Writer *writer;
  NSArray *objects;
  Reader *reader;

  START_SET("NSPasteboard writeObjects: and readObjectsForClasses:options:")

  NS_DURING
    {
      pb = [NSPasteboard pasteboardWithUniqueName];
      [pb types];
    }
  NS_HANDLER
    SKIP("pasteboard server is not available")
  NS_ENDHANDLER

  writer = AUTORELEASE([Writer new]);
  [pb clearContents];
  PASS([pb writeObjects: [NSArray arrayWithObject: writer]],
    "writeObjects: writes an NSPasteboardWriting object");
  PASS(writer->optionsAsked == 2,
    "the writer is asked for its options for each type");
  PASS([[pb types] containsObject: textType]
    && [[pb types] containsObject: listType],
    "the pasteboard holds the writer's types");
  PASS_EQUAL([pb stringForType: textType], @"some text",
    "a string value is written as a string");
  PASS_EQUAL([pb propertyListForType: listType],
    [NSDictionary dictionaryWithObject: @"value" forKey: @"key"],
    "a property list value is written as a property list");

  objects = [pb readObjectsForClasses: [NSArray arrayWithObject: [Reader class]]
			      options: nil];
  PASS([objects count] == 1, "readObjectsForClasses:options: reads an object");
  reader = [objects lastObject];
  PASS([reader isKindOfClass: [Reader class]], "the object is of the class");
  PASS(readingOptionsAsked == 1, "the class is asked for its reading options");
  PASS_EQUAL(reader->type, listType, "the object reads the type it can read");
  PASS_EQUAL(reader->value,
    [NSDictionary dictionaryWithObject: @"value" forKey: @"key"],
    "the object is made from the property list");

  objects = [pb readObjectsForClasses:
    [NSArray arrayWithObject: [TextReader class]] options: nil];
  reader = [objects lastObject];
  PASS_EQUAL(reader->value, @"some text",
    "a class reading a string is made from the string");

  [pb clearContents];
  PASS([[pb types] count] == 0, "clearContents empties the pasteboard");
  objects = [pb readObjectsForClasses: [NSArray arrayWithObject: [Reader class]]
			      options: nil];
  PASS(objects != nil && [objects count] == 0,
    "nothing is read from an empty pasteboard");
  PASS([pb writeObjects: [NSArray arrayWithObject: @"not a writer"]] == NO,
    "an object that cannot write is not written");

  [pb releaseGlobally];

  END_SET("NSPasteboard writeObjects: and readObjectsForClasses:options:")

  [pool release];
  return 0;
}
