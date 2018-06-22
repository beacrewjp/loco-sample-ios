//
//  WebViewController.m
//  LocoTutorial
//
//  Created by Y.Sekimoto on 2018/06/12.
//  Copyright © 2018 Beacrew Inc. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property WKWebView *webView;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [WKWebView new];
    self.webView.UIDelegate = self;
    self.webView.frame = self.baseView.frame;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                  | UIViewAutoresizingFlexibleBottomMargin
                                  | UIViewAutoresizingFlexibleRightMargin
                                  | UIViewAutoresizingFlexibleLeftMargin
                                  | UIViewAutoresizingFlexibleWidth
                                  | UIViewAutoresizingFlexibleHeight;
    [self.baseView addSubview:self.webView];

    NSString *path = [[NSBundle mainBundle] pathForResource:self.page ofType:@"html" inDirectory:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapHomeButton:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
