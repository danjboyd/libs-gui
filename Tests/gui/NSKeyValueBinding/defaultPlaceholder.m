/* +[NSObject setDefaultPlaceholder:forMarker:withBinding:] sets the
   placeholder a class's bindings show for a marker, or for a null value
   when the marker is nil, unless the binding's options give one, and
   +defaultPlaceholderForMarker:withBinding: answers it, for the class and
   its subclasses.  Neither method was implemented. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>

#include <AppKit/NSKeyValueBinding.h>

@interface Bound : NSObject
{
  id value;
}
- (id) value;
- (void) setValue: (id)aValue;
@end

@implementation Bound
+ (void) initialize
{
  if (self == [Bound class])
    {
      [self exposeBinding: NSValueBinding];
    }
}
- (void) dealloc
{
  RELEASE(value);
  [super dealloc];
}
- (id) value
{
  return value;
}
- (void) setValue: (id)aValue
{
  ASSIGN(value, aValue);
}
@end

@interface SubBound : Bound
@end
@implementation SubBound
@end

@interface Model : NSObject
{
  id name;
}
@end

@implementation Model
- (void) dealloc
{
  RELEASE(name);
  [super dealloc];
}
- (id) name
{
  return name;
}
- (void) setName: (id)aName
{
  ASSIGN(name, aName);
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  Model *model;
  Bound *bound;
  SubBound *sub;
  Bound *withOption;

  START_SET("NSObject default placeholders")

  PASS([Bound defaultPlaceholderForMarker: NSNoSelectionMarker
			      withBinding: NSValueBinding] == nil,
    "a class has no default placeholder at first");

  [Bound setDefaultPlaceholder: @"(nothing)"
		     forMarker: nil
		   withBinding: NSValueBinding];
  [Bound setDefaultPlaceholder: @"(none selected)"
		     forMarker: NSNoSelectionMarker
		   withBinding: NSValueBinding];
  PASS_EQUAL([Bound defaultPlaceholderForMarker: nil
				    withBinding: NSValueBinding],
    @"(nothing)", "the null placeholder is answered");
  PASS_EQUAL([Bound defaultPlaceholderForMarker: NSNoSelectionMarker
				    withBinding: NSValueBinding],
    @"(none selected)", "a marker's placeholder is answered");
  PASS([Bound defaultPlaceholderForMarker: NSNoSelectionMarker
			      withBinding: NSEnabledBinding] == nil,
    "the placeholder belongs to its binding");
  PASS_EQUAL([SubBound defaultPlaceholderForMarker: nil
				       withBinding: NSValueBinding],
    @"(nothing)", "a subclass has its superclass's placeholders");
  PASS([NSObject defaultPlaceholderForMarker: nil
				 withBinding: NSValueBinding] == nil,
    "a superclass does not have its subclass's placeholders");

  model = AUTORELEASE([Model new]);
  bound = AUTORELEASE([Bound new]);
  sub = AUTORELEASE([SubBound new]);
  withOption = AUTORELEASE([Bound new]);
  [bound bind: NSValueBinding toObject: model withKeyPath: @"name" options: nil];
  [sub bind: NSValueBinding toObject: model withKeyPath: @"name" options: nil];
  [withOption bind: NSValueBinding
	  toObject: model
       withKeyPath: @"name"
	   options: [NSDictionary dictionaryWithObject: @"(option)"
				    forKey: NSNullPlaceholderBindingOption]];

  PASS_EQUAL([bound value], @"(nothing)",
    "a binding shows the default placeholder for a null value");
  PASS_EQUAL([sub value], @"(nothing)",
    "a subclass's binding shows it too");
  PASS_EQUAL([withOption value], @"(option)",
    "a placeholder in the options comes first");

  [model setName: NSNoSelectionMarker];
  PASS_EQUAL([bound value], @"(none selected)",
    "a binding shows the default placeholder for a marker");
  [model setName: @"Ann"];
  PASS_EQUAL([bound value], @"Ann", "a value is shown as it is");

  [Bound setDefaultPlaceholder: nil
		     forMarker: NSNoSelectionMarker
		   withBinding: NSValueBinding];
  PASS([Bound defaultPlaceholderForMarker: NSNoSelectionMarker
			      withBinding: NSValueBinding] == nil,
    "setting a nil placeholder removes it");
  [model setName: NSNoSelectionMarker];
  PASS_EQUAL([bound value], @"No Selection",
    "without a placeholder the marker shows the usual text");

  [bound unbind: NSValueBinding];
  [sub unbind: NSValueBinding];
  [withOption unbind: NSValueBinding];

  END_SET("NSObject default placeholders")

  [pool release];
  return 0;
}
