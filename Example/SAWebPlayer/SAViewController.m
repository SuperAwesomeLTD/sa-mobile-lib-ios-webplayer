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
@property (nonatomic, strong) UIView *bannerAd;
@property (nonatomic, strong) SAWebPlayer *webPlayer;

@end

@implementation SAViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSString *img = @"<img src='https://ads.superawesome.tv/v2/demo_images/320x50.jpg'/>";
    NSString *rich = @"<iframe src='https://s3-eu-west-1.amazonaws.com/sb-ads-uploads/rich-media/tNmFLJ7kGQWBbyORkIqTJ4oqykaGPU9w/rich-media/index.html'/>";
    NSString *tag = @"<A HREF=\"[click]https://ad.doubleclick.net/ddm/jump/N304202.1915243SUPERAWESOME.TV/B10773905.144625054;sz=300x250;ord=[timestamp]?\"><IMG SRC=\"https://ad.doubleclick.net/ddm/ad/N304202.1915243SUPERAWESOME.TV/B10773905.144625054;sz=300x250;ord=[timestamp];dc_lat=;dc_rdid=;tag_for_child_directed_treatment=?\" BORDER=0 WIDTH=300 HEIGHT=250 ALT=\"Advertisement\"></A>";
    
    _bannerAd = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 300, 170)];
    _bannerAd.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview: _bannerAd];
    
    _webPlayer = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(300, 250)
                                           andParentFrame:_bannerAd.frame];
    [_bannerAd addSubview:_webPlayer];
    [_webPlayer setClickHandler:^(NSURL *url) {
        NSLog(@"Clicked on %@", [url absoluteString]);
    }];
    [_webPlayer loadHTML:tag];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) resize:(id)sender {
    [_bannerAd setFrame:CGRectMake(0, 50, 320, 240)];
    [_webPlayer updateParentFrame:_bannerAd.frame];
}
- (IBAction)reisze2:(id)sender {
    [_bannerAd setFrame:CGRectMake(0, 50, 120, 300)];
    [_webPlayer updateParentFrame:_bannerAd.frame];
}
- (IBAction)resize3:(id)sender {
    [_bannerAd setFrame:CGRectMake(0, 150, 245, 125)];
    [_webPlayer updateParentFrame:_bannerAd.frame];
}

@end
