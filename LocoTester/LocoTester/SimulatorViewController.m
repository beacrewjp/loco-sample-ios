//
//  SimulatorViewController.m
//  LocoTester
//
//  Created by Y.Sekimoto on 2018/09/06.
//  Copyright © 2018 Beacrew Inc. All rights reserved.
//

#import "SimulatorViewController.h"

@interface SimulatorViewController ()
@property (nonatomic, retain) CBPeripheralManager *peripheralManager;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property BOOL beaconIsReady;
@end

@implementation SimulatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource Methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];

    NSArray *clusters = [[BCLManager sharedManager] getClusters];
    BCLCluster *cluster = [clusters objectAtIndex:indexPath.section];

    NSArray *beacons = cluster.beacons;
    if ([beacons count] > 0) {
        BCLBeacon *beacon = [beacons objectAtIndex:indexPath.row];

        UILabel *name = [cell viewWithTag:101];
        name.text = beacon.name;
        
        UILabel *uuid = [cell viewWithTag:102];
        uuid.text = beacon.uuid;
        
        UILabel *major = [cell viewWithTag:103];
        major.text = [NSString stringWithFormat:@"%ld", (long)beacon.major];
        
        UILabel *minor = [cell viewWithTag:104];
        minor.text = [NSString stringWithFormat:@"%ld", (long)beacon.minor];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[BCLManager sharedManager] getClusters] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    NSArray *clusters = [[BCLManager sharedManager] getClusters];
    BCLCluster *cluster = [clusters objectAtIndex:section];
    if ([cluster.beacons count] > 0) {
        title = cluster.name;
    }
    return title;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *clusters = [[BCLManager sharedManager] getClusters];
    BCLCluster *cluster = [clusters objectAtIndex:section];
    return [cluster.beacons count];
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *clusters = [[BCLManager sharedManager] getClusters];
    BCLCluster *cluster = [clusters objectAtIndex:indexPath.section];
    
    NSArray *beacons = cluster.beacons;
    BCLBeacon *beacon = [beacons objectAtIndex:indexPath.row];

    [self startAdvertising:beacon.uuid major:beacon.major minor:beacon.minor];
}

#pragma mark - CBPeripheralManagerDelegate Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"%s", __FUNCTION__);
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"CBPeripheralManagerStatePoweredOn");
        self.beaconIsReady = YES;
    }
}

#pragma mark - Private Methods

- (void)startAdvertising:(NSString*)uuid major:(NSInteger)major minor:(NSInteger)minor {
    
    if ( ! self.beaconIsReady) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:@"ビーコンが発信可能状態になっていません"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                                           major:major
                                                                           minor:minor
                                                                      identifier:@"single"];
    
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
    
    [self.peripheralManager startAdvertising:beaconPeripheralData];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                message:@"ビーコン信号発信中"
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *stop = [UIAlertAction actionWithTitle:@"STOP"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [self stopAdvertising];
                                                     NSIndexPath *selected = self.tableView.indexPathForSelectedRow;
                                                     [self.tableView deselectRowAtIndexPath:selected animated:YES];
                                                 }];
    [ac addAction:stop];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)stopAdvertising {
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
}

@end
