#ifndef UIKEYBOARDIMPL_H
#define UIKEYBOARDIMPL_H

@interface UIKeyboardImpl

+(id)sharedInstance;
-(void)deleteBackward;
-(void)insertText: (NSString *) text withAlternativePredictions: (id) arg1;

@end

#endif