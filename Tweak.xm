// This code listens to every keypress and saves the last two keys pressed
// Don't worry, this cannot be used as a keylogger, unless your password is 2 digits long

#import <AudioToolbox/AudioServices.h>

@interface UIKeyboardImpl : UIView
- (void)deleteBackward;
@end

%hook UIKeyboardImpl

static NSString *lastTwoChars = [[NSString alloc] init];
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
								if (lastTwoChars.length < 2)
								{
																lastTwoChars = [[lastTwoChars stringByAppendingString:text] retain];
								}
								else
								{
																lastTwoChars = [[lastTwoChars substringFromIndex:1] retain];
																lastTwoChars = [[lastTwoChars stringByAppendingString:text] retain];
								}
								if ([lastTwoChars isEqualToString:@"\\u"])
								{
																AudioServicesPlaySystemSound(1352); // not using kSystemSoundID_Vibrate because 1352 ignores mute switch position
																typingSpecialChar = YES;
																hexChars = @""; // reset from last special character
								}
								if (!didOrig) {
																%orig;
								}
}

%end
