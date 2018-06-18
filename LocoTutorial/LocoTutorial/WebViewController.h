//
//  WebViewController.h
//  LocoTutorial
//
//  Created by Y.Sekimoto on 2018/06/12.
//  Copyright © 2018 Beacrew Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface WebViewController : UIViewController <WKUIDelegate>
@property (strong, nonatomic) NSString *page;
@end
