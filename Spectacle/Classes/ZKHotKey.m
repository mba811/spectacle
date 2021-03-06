#import "ZKHotKey.h"

#import "ZKHotKeyTranslator.h"

@implementation ZKHotKey

- (instancetype)initWithHotKeyCode:(NSInteger)hotKeyCode hotKeyModifiers:(NSUInteger)hotKeyModifiers
{
  if (self = [super init]) {
    _handle = -1;
    _hotKeyName = nil;
    _hotKeyAction = nil;
    _hotKeyCode = hotKeyCode;
    _hotKeyModifiers = [ZKHotKeyTranslator convertModifiersToCarbonIfNecessary:hotKeyModifiers];
    _hotKeyRef = NULL;
  }

  return self;
}

#pragma mark -

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithCoder:(NSCoder *)coder
{
  if (self = [super init]) {
    if ([coder allowsKeyedCoding]) {
      _hotKeyName = [coder decodeObjectForKey:@"name"];
      _hotKeyCode = [coder decodeIntegerForKey:@"keyCode"];
      _hotKeyModifiers = [coder decodeIntegerForKey:@"modifiers"];
    } else {
      _hotKeyName = [coder decodeObject];

      [coder decodeValueOfObjCType:@encode(NSInteger) at:&_hotKeyCode];
      [coder decodeValueOfObjCType:@encode(NSUInteger) at:&_hotKeyModifiers];
    }
  }

  return self;
}

#pragma clang diagnostic pop

#pragma mark -

- (void)encodeWithCoder:(NSCoder *)coder
{
  if ([coder allowsKeyedCoding]) {
    [coder encodeObject:self.hotKeyName forKey:@"name"];
    [coder encodeInteger:self.hotKeyCode forKey:@"keyCode"];
    [coder encodeInteger:self.hotKeyModifiers forKey:@"modifiers"];
  } else {
    [coder encodeObject:self.hotKeyName];
    [coder encodeValueOfObjCType:@encode(NSInteger) at:&_hotKeyCode];
    [coder encodeValueOfObjCType:@encode(NSUInteger) at:&_hotKeyModifiers];
  }
}

#pragma mark -

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if (encoder.isBycopy) {
    return self;
  }

  return [super replacementObjectForPortCoder:encoder];
}

#pragma mark -

+ (ZKHotKey *)clearedHotKey
{
  return [[ZKHotKey alloc] initWithHotKeyCode:0 hotKeyModifiers:0];
}

+ (ZKHotKey *)clearedHotKeyWithName:(NSString *)name
{
  ZKHotKey *hotKey = [[ZKHotKey alloc] initWithHotKeyCode:0 hotKeyModifiers:0];

  hotKey.hotKeyName = name;

  return hotKey;
}

#pragma mark -

- (void)triggerHotKeyAction
{
  if (self.hotKeyAction) {
    self.hotKeyAction(self);
  }
}

#pragma mark -

- (BOOL)isClearedHotKey
{
  return (self.hotKeyCode == 0) && (self.hotKeyModifiers == 0);
}

#pragma mark -

- (NSString *)displayString
{
  return [ZKHotKeyTranslator.sharedTranslator translateHotKey:self];
}

#pragma mark -

+ (BOOL)validCocoaModifiers:(NSUInteger)modifiers
{
  return ((modifiers & NSAlternateKeyMask)
          || (modifiers & NSCommandKeyMask)
          || (modifiers & NSControlKeyMask)
          || (modifiers & NSShiftKeyMask)
          || (modifiers & NSFunctionKeyMask));
}

#pragma mark -

- (BOOL)isEqual:(id)object
{
  if (object == self) {
    return YES;
  }

  if (!object || ![object isKindOfClass:[self class]]) {
    return NO;
  }

  return [self isEqualToHotKey:object];
}

- (BOOL)isEqualToHotKey:(ZKHotKey *)hotKey
{
  if (hotKey == self) {
    return YES;
  }

  if (hotKey.hotKeyCode != self.hotKeyCode) {
    return NO;
  }

  if (hotKey.hotKeyModifiers != self.hotKeyModifiers) {
    return NO;
  }

  return YES;
}

@end
