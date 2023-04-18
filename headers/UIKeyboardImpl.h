#ifndef UIKEYBOARDIMPL_H
#define UIKEYBOARDIMPL_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIKeyboardImpl : UIView

+(id)sharedInstance;
-(void)deleteBackward;
-(void)insertText: (NSString *) text withAlternativePredictions: (id) arg1;

@end

#endif