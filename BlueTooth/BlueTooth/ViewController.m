//
//  ViewController.m
//  BlueTooth
//
//  Created by sundusk on 2017/3/7.
//  Copyright © 2017年 sundusk. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
// 中心管理者
@property (nonatomic,strong) CBCentralManager *mgr;
// 扫描按钮
@property (weak, nonatomic) IBOutlet UIButton *scanBth;
// 连接的外设
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 默认情况下，扫描按钮是关闭的
    self.scanBth.enabled = NO;
    // 1.创建中心管理者
    self.mgr = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    
}

# pragma mark - 响应事件

// 点击扫描外设按钮后调用
- (IBAction)clickScanbth:(id)sender {

    NSLog(@"开始扫描");
    
    // 2.扫描外设
    
    [self.mgr scanForPeripheralsWithServices:nil options:nil];
    
}
#pragma mark - CBPeripheralDelegate

/**
 已经查找到外设中的服务后调用

 @param peripheral 外设
 @param error 错误
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    // 从外设的服务中匹配需求的服务
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:@"7E57"]) {
            // 5.查找需求服务中特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

/**
 已经查找到服务中的特征后调用

 @param peripheral 外设
 @param service 需求的服务
 @param error 错误
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    // 查找服务中匹配的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"B71E"]) {
            // 6.读写数据
            // 读取数据
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

/**
 已经更新特征中的数据后调用（读取特征的数据从该方法中进行）

 @param peripheral 外设
 @param characteristic 特征
 @param error 错误
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    NSData *data = characteristic.value;
    NSLog(@"读取数据 ：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString *str = @"你好外设，我是中心设备";
    
    // 写入数据
    [peripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    /**
     *
     typedef NS_ENUM(NSInteger, CBCharacteristicWriteType) {
     CBCharacteristicWriteWithResponse = 0, 发送后,有回执
     CBCharacteristicWriteWithoutResponse,   发送后,没有回执
     };
     */
}

/**
 已经写入数据后调用(只有设置CBCharacteristicWriteWithResponse才会响应该方法)

 @param peripheral 外设
 @param characteristic 特征
 @param error 错误
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"发送失败：%@", error);
    }else{
        NSLog(@"发送成功");
    }
}

# pragma mark - CBCentralManagerDelegate

/**
 已经连接外设后调用该方法

 @param central 中心设备
 @param peripheral 外设
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"连接外设成功");
    // 4.查找外设中设备
    [peripheral discoverServices:nil];
    // 查找外设的代理 获取查找情况
    peripheral.delegate = self;
    
    
}

/**
 找到外设后调用

 @param central 中心设备
 @param peripheral 外设
 @param advertisementData 广播数据（外设发出，中心根据这些信息来进行选择）
 @param RSSI 信号强弱 单位：分贝
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    // 3.有选择性的连接外设
    NSString *peripheralLocalName = advertisementData[CBAdvertisementDataLocalNameKey];
    NSLog(@"发现外设：%@",peripheralLocalName);
    // 匹配需要的外设
    if ([peripheralLocalName isEqualToString:@"传智外设"]){
        // 连接外设
        [self.mgr connectPeripheral:peripheral options:nil];
        // 进行连接操作时，必须强引用需要连接的外设
        self.peripheral = peripheral;
    }
}

/**
 作为中心的蓝牙设备已经更新状态后调用

 @param central <#central description#>
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    if (self.mgr.state == CBCentralManagerStatePoweredOn){
        
        // 蓝牙打开时，才能扫描外设
        self.scanBth.enabled = YES;
    }
    /**
     *
     
     typedef NS_ENUM(NSInteger, CBCentralManagerState) {
     CBCentralManagerStateUnknown = 0,  未知
     CBCentralManagerStateResetting,    重启
     CBCentralManagerStateUnsupported,  不支持BLE
     CBCentralManagerStateUnauthorized,  不识别
     CBCentralManagerStatePoweredOff,    关闭蓝牙
     CBCentralManagerStatePoweredOn,     打开蓝牙
     };
     */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
