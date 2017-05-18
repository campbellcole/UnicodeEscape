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

static unichar lastTwoChars[2]; // create array for storing two characters
static NSString *hexChars = [[NSString alloc] init]; // this will only be populating when typingSpecialChar == YES
static BOOL typingSpecialChar = NO; // will be YES when \u is typed
static BOOL didOrig = NO; // used to control %orig and not repeat it

- (void)insertText: (NSString *)text
{
  didOrig = NO; // set to NO until completed
  if (typingSpecialChar) // if \u was typed,
  {
    if ([text isEqualToString:@"\\"]) // if \ is typed (signaling completion)
    {
      typingSpecialChar = NO; // stop checking every character
      NSString *data = [NSString stringWithFormat:@"\\u%@",hexChars]; // isolate the hex characters
      // use encoding to find character from hex data
      NSString *toInsert = [NSString stringWithCString:[data cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
      for (int i = 0; i < hexChars.length+2; i++) // remove hex characters and \u
      {
        [self deleteBackward];
      }
      %orig(toInsert); // perform the original function with the new data
      AudioServicesPlaySystemSound(1352); // vibrate
      didOrig = YES; // make sure %orig isn't repeated
    }
    hexChars = [[hexChars stringByAppendingString:text] retain]; // add character to hexchar string
  }
  if (unistrlen(lastTwoChars) < 2) // if stored characters is less than two,
  {
    lastTwoChars[unistrlen(lastTwoChars)] = [text characterAtIndex:0]; // just add the character
  }
  else // otherwise
  {
    lastTwoChars[0] = lastTwoChars[1]; // index 0 becomes index 1
    lastTwoChars[1] = [text characterAtIndex:0]; // index 1 becomes current character
  }
  if ([[NSString stringWithCharacters:lastTwoChars length:2] isEqualToString:@"\\u"]) // if last two characters is \u,
  {
    AudioServicesPlaySystemSound(1352); // not using kSystemSoundID_Vibrate because 1352 ignores mute switch position
    typingSpecialChar = YES; // start checking every character
    hexChars = @""; // reset from last special character
  }
  if (!didOrig) { // if %orig isn't already performed, do it
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
