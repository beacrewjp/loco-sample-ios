//
//  ManagerViewController.m
//  LocoTester
//
//  Created by Y.Sekimoto on 2018/06/01.
//  Copyright 2018 Beacrew Inc.
//

#import "ManagerViewController.h"

@interface ManagerViewController ()

@end

@implementation ManagerViewController {
    __weak IBOutlet UILabel *appName;
    __weak IBOutlet UITextView *logText;
}

- (void)viewDidLoad {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];

    [BCLManager sharedManager].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidDisappear:animated];
}

#pragma mark - Rotate Event

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - IBAction Delegate

- (IBAction)tapKey:(UIButton *)button {

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *secretKey = [ud stringForKey:@"SDK_SECRET"];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"SECRET KEY"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = secretKey;
    }];

    [ac addAction:[UIAlertAction actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             UITextField *textField = ac.textFields.firstObject;
                                             [ud setObject:textField.text forKey:@"SDK_SECRET"];
                                             [ud synchronize];
                                         }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (IBAction)tapInit:(UIButton *)button {

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *secretKey = [ud stringForKey:@"SDK_SECRET"];

    if (secretKey && secretKey.length > 0) {
        BCLManager *manager = [BCLManager sharedManager];
        [manager initWithApiKey:secretKey autoScan:NO];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                    message:@"KEYが入力されていません"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (IBAction)tapScanStart:(UIButton *)button {
    [[BCLManager sharedManager] scanStart];
    NSMutableString *mstr = [NSMutableString string];
    [mstr appendString:[self currentTime]];
    [mstr appendString:@" [Info]    "];
    [mstr appendString:@"ScanStart"];
    [self addLogText:mstr color:[UIColor whiteColor]];
}

- (IBAction)tapScanStop:(UIButton *)button {
    [[BCLManager sharedManager] scanStop];
    NSMutableString *mstr = [NSMutableString string];
    [mstr appendString:[self currentTime]];
    [mstr appendString:@" [Info]    "];
    [mstr appendString:@"ScanStop"];
    [self addLogText:mstr color:[UIColor whiteColor]];
}

- (IBAction)tapInformation:(UIButton *)sender {

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:@"Device ID"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSMutableString *mstr = [NSMutableString string];
                                             [mstr appendString:@"[Device ID]\n"];
                                             [mstr appendFormat:@"%@", [[BCLManager sharedManager] getDeviceId]];
                                             [self addLogText:mstr color:[UIColor whiteColor]];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Nearest Beacon ID"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSMutableString *mstr = [NSMutableString string];
                                             [mstr appendString:@"[Nearest Beacon ID]\n"];
                                             [mstr appendFormat:@"%@", [[BCLManager sharedManager] getNearestBeaconId]];
                                             [self addLogText:mstr color:[UIColor whiteColor]];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Beacons"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSMutableString *mstr = [NSMutableString string];
                                             [mstr appendString:@"[Beacons]\n"];
                                             NSMutableArray *marray = [NSMutableArray array];
                                             NSArray *beacons = [[BCLManager sharedManager] getBeacons];
                                             if (beacons && beacons.count > 0) {
                                                 for (BCLBeacon *beacon in beacons) {
                                                     [marray addObject:[self beaconToDictionary:beacon]];
                                                 }
                                             }
                                             NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
                                             mdic[@"beacons"] = marray;
                                             [mstr appendString:[self makeJSONStringFromDictionary:mdic]];
                                             [self addLogText:mstr color:[UIColor whiteColor]];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Clusters"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSMutableString *mstr = [NSMutableString string];
                                             [mstr appendString:@"[Clusters]\n"];
                                             NSMutableArray *marray = [NSMutableArray array];
                                             NSArray *clusters = [[BCLManager sharedManager] getClusters];
                                             if (clusters && clusters.count > 0) {
                                                 for (BCLCluster *cluster in clusters) {
                                                     [marray addObject:[self clusterToDictionary:cluster]];
                                                 }
                                             }
                                             NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
                                             mdic[@"clusters"] = marray;
                                             [mstr appendString:[self makeJSONStringFromDictionary:mdic]];
                                             [self addLogText:mstr color:[UIColor whiteColor]];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Regions"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSMutableString *mstr = [NSMutableString string];
                                             [mstr appendString:@"[Regions]\n"];
                                             NSMutableArray *marray = [NSMutableArray array];
                                             NSArray *regions = [[BCLManager sharedManager] getRegions];
                                             if (regions && regions.count > 0) {
                                                 for (BCLRegion *region in regions) {
                                                     [marray addObject:[self regionToDictionary:region]];
                                                 }
                                             }
                                             NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
                                             mdic[@"regions"] = marray;
                                             [mstr appendString:[self makeJSONStringFromDictionary:mdic]];
                                             [self addLogText:mstr color:[UIColor whiteColor]];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Actions"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSMutableString *mstr = [NSMutableString string];
                                             [mstr appendString:@"[Actions]\n"];
                                             NSMutableArray *marray = [NSMutableArray array];
                                             NSArray *actions = [[BCLManager sharedManager] getActions];
                                             if (actions && actions.count > 0) {
                                                 for (BCLAction *action in actions) {
                                                     [marray addObject:[self actionToDictionary:action]];
                                                 }
                                             }
                                             NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
                                             mdic[@"actions"] = marray;
                                             [mstr appendString:[self makeJSONStringFromDictionary:mdic]];
                                             [self addLogText:mstr color:[UIColor whiteColor]];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Add Event Log"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             [self showEventLogDialog];
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action){
                                         }]];

    ac.popoverPresentationController.sourceView = self.view;
    ac.popoverPresentationController.sourceRect = sender.frame;
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - BCLManagerDelegate

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

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *mstr = [NSMutableString string];
        [mstr appendString:[self currentTime]];
        [mstr appendString:@" [Status]    "];
        [mstr appendString:stateString];
        [self addLogText:mstr color:[UIColor whiteColor]];
    });
}

- (void)didRangeBeacons:(NSArray *)beacons {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        BCLBeacon *beacon = [beacons firstObject];
        NSMutableString *mstr = [NSMutableString string];
        [mstr appendString:[self currentTime]];
        [mstr appendString:@" [Ranging]    "];
        [mstr appendString:beacon.name];
        [self addLogText:mstr color:[UIColor whiteColor]];
    });
}

- (void)didEnterRegion:(BCLRegion *)region {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *mstr = [NSMutableString string];
        [mstr appendString:[self currentTime]];
        [mstr appendString:@" [RegionIn]    "];
        [mstr appendString:region.name];
        [self addLogText:mstr color:[UIColor greenColor]];
    });
}

- (void)didExitRegion:(BCLRegion *)region {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *mstr = [NSMutableString string];
        [mstr appendString:[self currentTime]];
        [mstr appendString:@" [RegionOut]    "];
        [mstr appendString:region.name];
        [self addLogText:mstr color:[UIColor blueColor]];
    });
}

- (void)didActionCalled:(BCLAction *)action {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *mstr = [NSMutableString string];
        [mstr appendString:[self currentTime]];
        [mstr appendString:@" [Action]    "];
        [mstr appendString:action.name];
        [self addLogText:mstr color:[UIColor yellowColor]];
    });
}

- (void)didFailWithError:(BCLError *)error {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *mstr = [NSMutableString string];
        [mstr appendString:[self currentTime]];
        [mstr appendString:@" [Error]    "];
        [mstr appendString:error.message];
        [self addLogText:mstr color:[UIColor redColor]];
    });
}

#pragma mark - private method

- (void)showEventLogDialog {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Add Event Log"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"key";
    }];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"value";
    }];

    [ac addAction:[UIAlertAction actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSString *key = ac.textFields[0].text;
                                             NSString *value = ac.textFields[1].text;
                                             if (key.length > 0 && value.length > 0) {
                                                 [[BCLManager sharedManager] addEventLog:key value:value];
                                                 NSMutableString *mstr = [NSMutableString string];
                                                 [mstr appendString:@"[Add Event Log]\n"];
                                                 [mstr appendString:[NSString stringWithFormat:@"key : %@\n", key]];
                                                 [mstr appendString:[NSString stringWithFormat:@"value : %@", value]];
                                                 [self addLogText:mstr color:[UIColor whiteColor]];
                                             }
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action){
                                         }]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (NSString *)currentTime {
    NSDateFormatter *readableDateFormat = [[NSDateFormatter alloc] init];
    [readableDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
    return [readableDateFormat stringFromDate:[NSDate date]];
}

- (void)addLogText:(NSString *)text color:(UIColor *)color {
    NSMutableAttributedString *attributedText = [logText.attributedText mutableCopy];
    NSMutableString *mstr = [NSMutableString stringWithString:text];
    [mstr appendString:@"\n"];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
    NSAttributedString *astr = [[NSAttributedString alloc] initWithString:mstr attributes:attributes];
    [attributedText appendAttributedString:astr];
    logText.attributedText = attributedText;
    [logText scrollRangeToVisible:NSMakeRange(logText.text.length - 1, 1)];
}

- (NSDictionary *)beaconToDictionary:(BCLBeacon *)beacon {
    NSMutableDictionary *beaconDictionary = [NSMutableDictionary dictionary];
    beaconDictionary[@"beaconId"] = beacon.beaconId;
    beaconDictionary[@"name"] = beacon.name;
    beaconDictionary[@"uuid"] = beacon.uuid;
    beaconDictionary[@"major"] = @(beacon.major);
    beaconDictionary[@"minor"] = @(beacon.minor);
    beaconDictionary[@"txPower"] = @(beacon.txPower);
    beaconDictionary[@"rssi"] = @(beacon.rssi);
    beaconDictionary[@"localName"] = beacon.localName;
    beaconDictionary[@"moduleId"] = beacon.moduleId;
    beaconDictionary[@"model"] = beacon.model;
    beaconDictionary[@"manufacturer"] = beacon.manufacturer;
    beaconDictionary[@"x"] = @(beacon.x);
    beaconDictionary[@"y"] = @(beacon.y);
    beaconDictionary[@"height"] = @(beacon.height);
    NSMutableArray *actionsArray = [NSMutableArray array];
    for (BCLAction *action in beacon.actions) {
        [actionsArray addObject:[self actionToDictionary:action]];
    }
    beaconDictionary[@"actions"] = actionsArray;
    
    return beaconDictionary;
}

- (NSDictionary *)actionToDictionary:(BCLAction *)action {
    NSMutableDictionary *actionDictionary = [NSMutableDictionary dictionary];
    actionDictionary[@"actionId"] = action.actionId;
    actionDictionary[@"name"] = action.name;
    actionDictionary[@"uri"] = (action.uri) ? action.uri : [NSNull null];
    actionDictionary[@"interval"] = @(action.interval);
    NSMutableArray *paramsArray = [NSMutableArray array];
    for (BCLParam *param in action.params) {
        [paramsArray addObject:[self paramToDictionary:param]];
    }
    actionDictionary[@"params"] = paramsArray;
    
    return actionDictionary;
}

- (NSDictionary *)regionToDictionary:(BCLRegion *)region {
    NSMutableDictionary *regionDictionary = [NSMutableDictionary dictionary];
    regionDictionary[@"regionId"] = region.regionId;
    regionDictionary[@"name"] = region.name;
    regionDictionary[@"type"] = region.type;
    regionDictionary[@"uuid"] = (region.uuid) ? region.uuid : [NSNull null];
    regionDictionary[@"major"] = (region.major) ? region.major : [NSNull null];
    regionDictionary[@"minor"] = (region.minor) ? region.minor : [NSNull null];
    regionDictionary[@"latitude"] = (region.latitude) ? region.latitude : [NSNull null];
    regionDictionary[@"longitude"] = (region.longitude) ? region.longitude : [NSNull null];
    regionDictionary[@"radius"] = (region.radius) ? region.radius : [NSNull null];
    NSMutableArray *inActionArray = [NSMutableArray array];
    for (BCLAction *action in region.inAction) {
        [inActionArray addObject:[self actionToDictionary:action]];
    }
    regionDictionary[@"inAction"] = inActionArray;
    NSMutableArray *outActionArray = [NSMutableArray array];
    for (BCLAction *action in region.outAction) {
        [outActionArray addObject:[self actionToDictionary:action]];
    }
    regionDictionary[@"outAction"] = outActionArray;
    
    return regionDictionary;
}

- (NSDictionary *)clusterToDictionary:(BCLCluster *)cluster {
    NSMutableDictionary *clusterDictionary = [NSMutableDictionary dictionary];
    clusterDictionary[@"clusterId"] = cluster.clusterId;
    clusterDictionary[@"parentId"] = (cluster.parentId) ? cluster.parentId : [NSNull null];
    clusterDictionary[@"name"] = cluster.name;
    clusterDictionary[@"tag"] = cluster.tag;
    clusterDictionary[@"image"] = (cluster.image) ? cluster.image : [NSNull null];
    NSMutableArray *beaconsArray = [NSMutableArray array];
    for (BCLBeacon *beacon in cluster.beacons) {
        [beaconsArray addObject:[self beaconToDictionary:beacon]];
    }
    clusterDictionary[@"beacons"] = beaconsArray;
    
    return clusterDictionary;
}

- (NSDictionary *)paramToDictionary:(BCLParam *)param {
    NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionary];
    paramDictionary[@"key"] = param.key;
    paramDictionary[@"value"] = param.value;
    
    return paramDictionary;
}

- (NSString *)makeJSONStringFromDictionary:(NSDictionary *)dictionary {
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

@end
