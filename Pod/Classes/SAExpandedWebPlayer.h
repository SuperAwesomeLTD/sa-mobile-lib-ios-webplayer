#import "SAWebPlayer.h"

@interface SAExpandedWebPlayer : SAWebPlayer

@property (nonatomic, strong) UIButton *closeBtn;

- (void) updateCloseBtnFrame:(SACustomClosePosition) closePos;

@end
