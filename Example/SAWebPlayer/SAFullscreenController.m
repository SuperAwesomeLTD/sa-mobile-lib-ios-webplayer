//
//  SAFullscreenController.m
//  SAWebPlayer_Example
//
//  Created by Gabriel Coman on 18/06/2018.
//  Copyright © 2018 Gabriel Coman. All rights reserved.
//

#import "SAFullscreenController.h"
#import "SAWebPlayer.h"

@interface SAFullscreenController ()

@property (nonatomic, strong) SAWebPlayer *webPlayer1;

@property (weak, nonatomic) IBOutlet UIView *adSupport1;

@end

@implementation SAFullscreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // recreate
    _webPlayer1 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 480) andParentFrame:_adSupport1.frame];
    [_adSupport1 addSubview:_webPlayer1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ad2" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer1 setClickHandler:^(NSURL *url) {
        NSLog(@"Should go to url %@", [url absoluteString]);
    }];
    [_webPlayer1 loadHTML:ad witBase:@"https://s3-eu-west-1.amazonaws.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
