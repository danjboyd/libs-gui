/* Interface Builder names a Swift class with customClass and customModule.
 * Cocoa's runtime registers such a class under its module-qualified name,
 * Module.Class, so the unarchiver has to instantiate the class of that name.
 * A class declared @objc(Name) keeps its bare name, so the bare name is used
 * when no class has the qualified one.
 *
 * Objective-C cannot declare a class named Module.Class, so the test
 * registers the qualified classes at run time, as the Swift runtime does.
 */
#import "ObjectTesting.h"

#import <objc/runtime.h>
#import <Foundation/NSData.h>
#import <Foundation/NSProcessInfo.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSView.h>
#import <Additions/GNUstepGUI/GSXibKeyedUnarchiver.h>
#import <Additions/GNUstepGUI/GSNibLoading.h>

@interface BareObject : NSObject
@end

@implementation BareObject
@end

static void
registerClass(Class superclass, const char *name)
{
  Class cls = objc_allocateClassPair(superclass, name, 0);

  objc_registerClassPair(cls);
}

static id
objectOfClassNamed(NSArray *objects, NSString *name)
{
  NSEnumerator *enumerator = [objects objectEnumerator];
  id element;

  while ((element = [enumerator nextObject]) != nil)
    {
      NSString *className = NSStringFromClass([element class]);

      /* A custom object is decoded as a placeholder that makes an object
         of the class it names when the nib is instantiated. */
      if ([element isKindOfClass: [NSCustomObject class]])
        {
          className = [element className];
        }
      if ([className isEqualToString: name]
        && NSClassFromString(className) != Nil)
        {
          return element;
        }
    }
  return nil;
}

int main()
{
  START_SET("GSXib5KeyedUnarchiver customModule tests")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name]
	isEqualToString: NSInternalInconsistencyException ])
	{
	  SKIP("It looks like GNUstep backend is not yet installed")
	}
    }
  NS_ENDHANDLER

  NSData	*data;
  id		unarchiver;
  NSArray	*rootObjects;
  id		button;

  registerClass([NSObject class], "XibTest.ModuleObject");
  registerClass([NSView class], "XibTest.ModuleView");
  registerClass([NSButton class], "XibTest.ModuleButton");
  registerClass([NSObject class], [[NSString stringWithFormat: @"%@.TargetObject",
    [[NSProcessInfo processInfo] processName]] UTF8String]);

  data = [NSData dataWithContentsOfFile: @"CustomModule.xib"];
  unarchiver = [GSXibKeyedUnarchiver unarchiverForReadingWithData: data];
  rootObjects = [unarchiver decodeObjectForKey: @"IBDocument.RootObjects"];

  PASS(objectOfClassNamed(rootObjects, @"XibTest.ModuleObject") != nil,
    "a custom object is instantiated by its module-qualified name")
  PASS(objectOfClassNamed(rootObjects, @"XibTest.ModuleView") != nil,
    "a custom view is instantiated by its module-qualified name")

  button = objectOfClassNamed(rootObjects, @"XibTest.ModuleButton");
  PASS(button != nil,
    "a control is instantiated by its module-qualified name")
  PASS_EQUAL([button title], @"QUALIFIED",
    "the control keeps the attributes of its element")

  PASS(objectOfClassNamed(rootObjects, [NSString stringWithFormat:
    @"%@.TargetObject", [[NSProcessInfo processInfo] processName]]) != nil,
    "customModuleProvider=\"target\" names the program's module")

  PASS(objectOfClassNamed(rootObjects, @"BareObject") != nil,
    "a class without a module-qualified name keeps its bare name")

  END_SET("GSXib5KeyedUnarchiver customModule tests")

  return 0;
}
