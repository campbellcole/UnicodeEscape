// This code listens to every keypress and saves the last two keys pressed
// Don't worry, this cannot be used as a keylogger, unless your password is 2 digits long

#import <AudioToolbox/AudioServices.h>

@interface UIKeyboardImpl : UIView
- (void)deleteBackward;
@end

unsigned long long unistrlen(unichar chars[])
{
  unsigned long long length = 0llu;
  if(NULL == chars) return length;

  while(0 != chars[length])
  length++;

  return length;
}

%hook UIKeyboardImpl

static unichar lastTwoChars[2];
static NSString *hexChars = [[NSString alloc] init]; // this will only be populating when typingSpecialChar == YES
static BOOL typingSpecialChar = NO;
static BOOL didOrig = NO;

- (void)insertText: (NSString *)text
{
  didOrig = NO;
  if (typingSpecialChar)
  {
    if ([text isEqualToString:@"\\"])
    {
      typingSpecialChar = NO;
      NSString *data = [NSString stringWithFormat:@"\\u%@",hexChars];
      NSString *toInsert = [NSString stringWithCString:[data cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
      for (int i = 0; i < hexChars.length+2; i++)
      {
        [self deleteBackward];
      }
      %orig(toInsert);
      AudioServicesPlaySystemSound(1352);
      didOrig = YES;
    }
    hexChars = [[hexChars stringByAppendingString:text] retain];
  }
  if (unistrlen(lastTwoChars) < 2)
  {
    lastTwoChars[unistrlen(lastTwoChars)] = [text characterAtIndex:0];
  }
  else
  {
    lastTwoChars[0] = lastTwoChars[1];
    lastTwoChars[1] = [text characterAtIndex:0];
  }
  if ([[NSString stringWithCharacters:lastTwoChars length:2] isEqualToString:@"\\u"])
  {
    AudioServicesPlaySystemSound(1352); // not using kSystemSoundID_Vibrate because 1352 ignores mute switch position
    typingSpecialChar = YES;
    hexChars = @""; // reset from last special character
  }
  if (!didOrig) {
    %orig;
  }
}



/*- (void)deleteFromInput
{
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"delete" message:@"delete" delegate:nil cancelButtonTitle:@"Okie" otherButtonTitles:nil];
[alert show];
[alert release];
lastTwoChars = [[lastTwoChars substringToIndex:lastTwoChars.length-(lastTwoChars.length>0)] retain];
hexChars = [[hexChars substringToIndex:hexChars.length-(hexChars.length>0)] retain];
%orig;
}*/

%end
