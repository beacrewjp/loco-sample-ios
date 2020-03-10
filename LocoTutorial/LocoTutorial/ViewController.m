//
//  ViewController.m
//  LocoTutorial
//
//  Created by Y.Sekimoto on 2018/06/12.
//  Copyright © 2018 Beacrew Inc. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIAlertController *alert;
@end

@implementation ViewController

// SDK SECRETをセット
static NSString *kSDKSecret = @"<ENTER YOUR SDK SECRET>";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.alert = nil;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(3.0f, 3.0f);
    self.indicator.transform = transform;
    [self.indicator startAnimating];
    
    BCLManager *manager = [BCLManager sharedManager];
    manager.delegate = self;
    [manager initWithApiKey:kSDKSecret autoScan:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toWebView"]) {
        WebViewController *controller = segue.destinationViewController;
        controller.page = sender;
    }
}

#pragma mark - BCLManagerDelegate Methods

- (void)didActionCalled:(BCLAction *)action type:(NSString *)type source:(id)source {

    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    for (BCLParam *param in action.params) {
        [mdic setObject:param.value forKey:param.key];
    }

    NSString *actionType = mdic[@"type"];
    
    if ([actionType isEqualToString:@"web"]) {
        
        NSString *page = mdic[@"page"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.presentedViewController) {
                if ([self.presentedViewController isEqual:self.alert]) {
                    [self.alert dismissViewControllerAnimated:NO completion:^{
                        [self showDialog:page];
                    }];
                }
            } else {
                [self showDialog:page];
            }
            
        });

    } else if ([actionType isEqualToString:@"push"]) {
        
        NSString *message = mdic[@"message"];
        
        [self pushMessage:message];
    }
}

#pragma mark - Private Methods

- (void)showDialog:(NSString *)page {
    
    self.alert = [UIAlertController alertControllerWithTitle:page
                                                     message:@"製品カタログを表示します。"
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [[BCLManager sharedManager] addEventLog:@"Open" value:page];
                                                   [self performSegueWithIdentifier:@"toWebView" sender:page];
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                   }];

    [self.alert addAction:ok];
    [self.alert addAction:cancel];
    [self presentViewController:self.alert animated:YES completion:nil];
}

- (void)pushMessage:(NSString *)message {
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = message;
    content.sound = [UNNotificationSound defaultSound];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString
                                                                          content:content
                                                                          trigger:nil];
    
    UNUserNotificationCenter *currentCenter = [UNUserNotificationCenter currentNotificationCenter];
    [currentCenter addNotificationRequest:request
                    withCompletionHandler:^(NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"notification error:%@", error.localizedDescription);
                        }
                    }];
}

@end
