
#import <AudioToolbox/AudioServices.h>

@interface UIKeyboardImpl : UIView
- (void) deleteBackward;
@end

unsigned long long unistrlen(unichar chars[])
{
  unsigned long long length = 0llu;
  if (NULL == chars) return length;

  while (0 != chars[length]) length++;

  return length;
}

%hook UIKeyboardImpl

static unichar lt[2];
static unichar hex[4];

static BOOL didOrig = NO;
static BOOL listening = NO;

- (void) insertText: (NSString *)text
{
  didOrig = NO; // just in case
  if (listening)
  {
    if ([text isEqualToString:@"\\"])
    {
      listening = NO;
      NSString *data = [NSString stringWithFormat:@"\\u%@", [NSString stringWithCharacters:hex length:4]];
      NSString *outp = [NSString stringWithCString:[data cStringUsingEncoding:NSUTF8StringEncoding] encoding: NSNonLossyASCIIStringEncoding];
      for (int i = 0; i < unistrlen(hex)+2; i++) {
        [self deleteBackward];
      }
      %orig(outp);
      AudioServicesPlaySystemSound(1352);
      didOrig = YES;
    }
    hex[0]=hex[1];
    hex[1]=hex[2];
    hex[2]=hex[3];
    hex[3]= [text characterAtIndex:0];
  }
  lt[0] = lt[1];
  lt[1] = [text characterAtIndex:0];
  if ([[NSString stringWithCharacters:lt length:2] isEqualToString:@"\\u"])
  {
    AudioServicesPlaySystemSound(1352);
    listening = YES;
  }
  if (!didOrig)
  {
    %orig;
  }
}

%end
