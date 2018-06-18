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
    
    CGAffineTransform transform = CGAffineTransformMakeScale(5.0f, 5.0f);
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

- (void)didChangeInitStatus:(BCLInitState)status {
    NSString *stateString = @"";
    switch (status) {
        case BCLInitStateInitializing:
            stateString = @"Initializing";
            break;
        case BCLInitStateReady:
            stateString = @"Ready";
            break;
        case BCLInitStateError:
            stateString = @"Error";
            break;
        default:
            stateString = @"Unknown";
            break;
    }
    NSLog(@"%s:%@", __FUNCTION__, stateString);
}

- (void)didActionCalled:(BCLAction *)action {

    for (BCLParam *param in action.params) {
        if ([param.key isEqualToString:@"page"]) {
            if (self.presentedViewController) {
                if ([self.presentedViewController isEqual:self.alert]) {
                    [self.alert dismissViewControllerAnimated:YES completion:^{
                        [self showDialog:param.value];
                    }];
                }
            } else {
                [self showDialog:param.value];
            }
        }
    }
}

- (void)didEnterRegion:(BCLRegion *)region {
    
    NSMutableString *message = [NSMutableString string];
    [message appendString:region.name];
    [message appendString:@"へチェックインしました。"];
    [self pushMessage:message];
}

#pragma mark - Private Methods

- (void)showDialog:(NSString *)page {
    
    self.alert = [UIAlertController alertControllerWithTitle:page
                                                     message:@"製品カタログを表示します。"
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
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
