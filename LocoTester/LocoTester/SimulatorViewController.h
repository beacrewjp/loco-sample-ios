//
//  SimulatorViewController.h
//  LocoTester
//
//  Created by Y.Sekimoto on 2018/09/06.
//  Copyright © 2018 Beacrew Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <BeacrewLoco/BeacrewLoco.h>

@interface SimulatorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CBPeripheralManagerDelegate>

@end
