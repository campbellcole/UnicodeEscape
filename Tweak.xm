#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "headers/UIKBTree.h"
#import "headers/UIKeyboardImpl.h"

// #define DEBUG_LOGGING
#ifdef DEBUG_LOGGING

#define LOG(...) \
    NSLog(@"[UnicodeEscape15] " __VA_ARGS__)

#else

#define LOG(...) {}

#endif

// no constant for this value because it's private
#define SYSTEM_SOUND_VIBRATE 1352

#define LAST_TWO_COUNT 2
#define HEX_CHARS_COUNT 4

static unichar lastTwoTypedChars[LAST_TWO_COUNT];
static unichar hexChars[HEX_CHARS_COUNT];

void shiftIn(unichar chars[], unsigned long count, unichar c)
{
    unsigned long pos = 0;

    // don't touch the last character because it would overflow with pos + 1
    while (pos < count - 1)
    {
        chars[pos] = chars[pos + 1];
        pos += 1;
    }

    chars[count - 1] = c;
}

static BOOL listening = NO;

@interface UIKeyboardLayoutStar
-(void)clearAllTouchInfo;
@end

%hook UIKeyboardLayoutStar

- (void) touchDownWithKey: (UIKBTree *) key withTouchInfo: (id) arg1 atPoint: (struct CGPoint) arg2 executionContext: (id) arg3
{
    // typing a letter is interaction type of 2
    if ([key interactionType] != 2)
    {
        LOG("ignoring key press: %@", [key name]);
        %orig;
        return;
    }

    unichar c = [[key displayString] characterAtIndex:0];
    LOG("received character: %C", c);

    if (!listening)
    {
        // we are not currently accepting hex characters
        // so we need to check if `\u` was typed
        shiftIn(lastTwoTypedChars, LAST_TWO_COUNT, c);

        if ([[NSString stringWithCharacters:lastTwoTypedChars length:LAST_TWO_COUNT] isEqualToString:@"\\u"])
        {
            listening = YES;
            AudioServicesPlaySystemSound(SYSTEM_SOUND_VIBRATE);
            LOG("'\\u' typed! listening mode on");
        }

        %orig;
    }
    else
    {
        if (c != '\\')
        {
            shiftIn(hexChars, HEX_CHARS_COUNT, c);
            LOG("char shifted in. hexChars: %C%C%C%C", hexChars[0], hexChars[1], hexChars[2], hexChars[3]);
            %orig;
        }
        else
        {
            listening = NO;
            // put the typed hex characters in a string
            NSString *hexString = [NSString stringWithCharacters:hexChars length:HEX_CHARS_COUNT];
            LOG("hexString: %@", hexString);
            // format it into a unicode escape sequence literal
            NSString *escapeSequence = [NSString stringWithFormat:@"\\u%@", hexString];
            LOG("escapeSequence: %@", escapeSequence);
            // decode the string into a c string
            const char *decoded = [escapeSequence cStringUsingEncoding:NSUTF8StringEncoding];
            LOG("decoded: %s", decoded);
            // re-encode the string to parse the escape sequence
            NSString *encoded = [NSString stringWithCString:decoded encoding:NSNonLossyASCIIStringEncoding];
            LOG("encoded: %@", encoded);

            // figured this one out through trial and error
            // if this function isn't called before %orig, the pressed character
            // will still be typed because there is a delay after returning calling %orig
            // to the character being typed. if %orig is never called, the keyboard becomes
            // deadlocked because the touch is never resolved. the only alternative is
            // to trigger a task a few milliseconds after this %orig call, but that seems cumbersome
            [self clearAllTouchInfo];
            %orig; // run orig so we don't freeze the keyboard
            LOG("cleared touch info then ran %%orig. the pressed key will be skipped.");

            UIKeyboardImpl *kb = [UIKeyboardImpl sharedInstance];
            for (int i = 0; i < HEX_CHARS_COUNT + 2; i++)
            {
                [kb deleteBackward];
            }
            LOG("deleted %d chars", HEX_CHARS_COUNT + 2);

            [kb insertText:encoded withAlternativePredictions:nil];
            LOG("inserted encoded character");

            AudioServicesPlaySystemSound(SYSTEM_SOUND_VIBRATE);
        }
    }
}

%end

%ctor {
    LOG("ctor called! %f", kCFCoreFoundationVersionNumber);
}