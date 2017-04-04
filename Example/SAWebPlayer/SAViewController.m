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
    
//    NSString *img = @"<img src='https://ads.superawesome.tv/v2/demo_images/320x50.jpg'/>";
//    NSString *rich = @"<iframe src='https://s3-eu-west-1.amazonaws.com/sb-ads-uploads/rich-media/tNmFLJ7kGQWBbyORkIqTJ4oqykaGPU9w/rich-media/index.html'/>";
//    NSString *tag = @"<A HREF=\"[click]https://ad.doubleclick.net/ddm/jump/N304202.1915243SUPERAWESOME.TV/B10773905.144625054;sz=300x250;ord=[timestamp]?\"><IMG SRC=\"https://ad.doubleclick.net/ddm/ad/N304202.1915243SUPERAWESOME.TV/B10773905.144625054;sz=300x250;ord=[timestamp];dc_lat=;dc_rdid=;tag_for_child_directed_treatment=?\" BORDER=0 WIDTH=300 HEIGHT=250 ALT=\"Advertisement\"></A>";
//    NSString *rich2 = @"<iframe src='https://s3-eu-west-1.amazonaws.com/sb-ads-uploads/rich-media/H1KI1dTnKhSPLDAbLtpN7zgqTOO9qNsO/Ooshies/index.html'/>";
//    
//    _bannerAd = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 300, 170)];
//    _bannerAd.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview: _bannerAd];
//    
//    _webPlayer = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(320, 480)
//                                           andParentFrame:_bannerAd.frame];
//    [_bannerAd addSubview:_webPlayer];
//    [_webPlayer setClickHandler:^(NSURL *url) {
//        NSLog(@"Clicked on %@", [url absoluteString]);
//    }];
//    [_webPlayer loadHTML:rich2 witBase:@"https://s3-eu-west-1.amazonaws.com"];
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
    
}

- (IBAction)mraid2:(id)sender {
    
}

- (IBAction)mraid3:(id)sender {
    
}

- (IBAction)mraid4:(id)sender {
    
}
@end
