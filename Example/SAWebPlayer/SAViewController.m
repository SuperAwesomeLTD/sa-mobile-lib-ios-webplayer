//
//  SAViewController.m
//  SAWebPlayer
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

#import "SAViewController.h"
#import "SAWebPlayer.h"

@interface SAViewController ()

@property (nonatomic, strong) SAWebPlayer *webPlayer1;
@property (nonatomic, strong) SAWebPlayer *webPlayer2;

@property (weak, nonatomic) IBOutlet UIView *adSupport1;
@property (weak, nonatomic) IBOutlet UIView *adSupport2;

@end

@implementation SAViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)ad1:(id)sender {
    
    // stop
    if (_webPlayer1 != nil) {
        [_webPlayer1 removeFromSuperview];
        _webPlayer1 = nil;
    }
    
    // recreate
    _webPlayer1 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 50) andParentFrame:_adSupport1.frame];
    [_adSupport1 addSubview:_webPlayer1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ad1" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer1 loadHTML:ad witBase:@"https://s3-eu-west-1.amazonaws.com"];
    
}

- (IBAction)ad2:(id)sender {
    
    // stop
    if (_webPlayer1 != nil) {
        [_webPlayer1 removeFromSuperview];
        _webPlayer1 = nil;
    }
    
    // recreate
    _webPlayer1 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(300, 250) andParentFrame:_adSupport1.frame];
    [_adSupport1 addSubview:_webPlayer1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ad2" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer1 loadHTML:ad witBase:@"https://s3-eu-west-1.amazonaws.com"];
    
}

- (IBAction)ad3:(id)sender {
    
    // stop
    if (_webPlayer1 != nil) {
        [_webPlayer1 removeFromSuperview];
        _webPlayer1 = nil;
    }
    
    // recreate
    _webPlayer1 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 480) andParentFrame:_adSupport1.frame];
    [_adSupport1 addSubview:_webPlayer1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ad3" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer1 loadHTML:ad witBase:@"https://s3-eu-west-1.amazonaws.com"];
    
}

- (IBAction)ad4:(id)sender {
    
    // stop
    if (_webPlayer1 != nil) {
        [_webPlayer1 removeFromSuperview];
        _webPlayer1 = nil;
    }
    
    // recreate
    _webPlayer1 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 480) andParentFrame:_adSupport1.frame];
    [_adSupport1 addSubview:_webPlayer1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ad4" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer1 loadHTML:ad witBase:@"https://s3-eu-west-1.amazonaws.com"];
    
}

- (IBAction)ad5:(id)sender {
    
    // stop
    if (_webPlayer1 != nil) {
        [_webPlayer1 removeFromSuperview];
        _webPlayer1 = nil;
    }
    
    // recreate
    _webPlayer1 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 480) andParentFrame:_adSupport1.frame];
    [_adSupport1 addSubview:_webPlayer1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ad5" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer1 loadHTML:ad witBase:@"https://s3-eu-west-1.amazonaws.com"];
    
}

- (IBAction)mraid1:(id)sender {
    
    // stop
    if (_webPlayer2 != nil) {
        [_webPlayer2 removeFromSuperview];
        _webPlayer2 = nil;
    }
    
    // recreate
    _webPlayer2 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 50) andParentFrame:_adSupport2.frame];
    [_adSupport2 addSubview:_webPlayer2];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mraid1" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer2 loadHTML:ad witBase:nil];
    
}

- (IBAction)mraid2:(id)sender {
    
    // stop
    if (_webPlayer2 != nil) {
        [_webPlayer2 removeFromSuperview];
        _webPlayer2 = nil;
    }
    
    // recreate
    _webPlayer2 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 50) andParentFrame:_adSupport2.frame];
    [_adSupport2 addSubview:_webPlayer2];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mraid2" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer2 loadHTML:ad witBase:nil];
    
}

- (IBAction)mraid3:(id)sender {
 
    // stop
    if (_webPlayer2 != nil) {
        [_webPlayer2 removeFromSuperview];
        _webPlayer2 = nil;
    }
    
    // recreate
    _webPlayer2 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 50) andParentFrame:_adSupport2.frame];
    [_adSupport2 addSubview:_webPlayer2];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mraid3" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer2 loadHTML:ad witBase:nil];
    
}

- (IBAction)mraid4:(id)sender {
    
    // stop
    if (_webPlayer2 != nil) {
        [_webPlayer2 removeFromSuperview];
        _webPlayer2 = nil;
    }
    
    // recreate
    _webPlayer2 = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 50) andParentFrame:_adSupport2.frame];
    [_adSupport2 addSubview:_webPlayer2];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mraid4" ofType:@"txt"];
    NSString *ad = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [_webPlayer2 loadHTML:ad witBase:nil];
    
}
@end
