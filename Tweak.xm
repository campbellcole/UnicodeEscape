// This code listens to every keypress and saves the last two keys pressed
// Don't worry, this cannot be used as a keylogger, unless your password is 2 digits long

%hook UIKeyboardImpl

static NSString *lastTwoChars = [[NSString alloc] init];

- (void)insertText: (NSString *)text
{
								if (lastTwoChars.length < 2) {
																lastTwoChars = [[lastTwoChars stringByAppendingString:text] retain];
								} else {
																lastTwoChars = [[lastTwoChars substringFromIndex:1] retain];
																lastTwoChars = [[lastTwoChars stringByAppendingString:text] retain];
								}
								if ([lastTwoChars isEqualToString:@"\\u"]) {
																UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Text-Entered" message:@"entered \\u" delegate:nil cancelButtonTitle:@"Neat-o!" otherButtonTitles:nil];
																[alert show];
																[alert release];
								}

								%orig;
}

%end
