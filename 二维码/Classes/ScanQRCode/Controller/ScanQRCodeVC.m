//
//  ScanQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "ScanQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanQRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toBottom;
@property (weak, nonatomic) IBOutlet UIView *scanBackView;
@property (weak, nonatomic) IBOutlet UIImageView *chongjiboImageView;

@property (nonatomic, strong) AVCaptureSession *session;
@end

@implementation ScanQRCodeVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startScanAnimation];
}
- (void)startScan{
    // 1. 设置输入
    // 1.1 获取摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 1.2 把摄像头设备当做输入设备
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    // 2. 设置输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 2.1 设置结果处理的代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 3. 创建会话，连接输入和输出
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    if ([session canAddInput:input] && [session canAddOutput:output]) {
        [session addInput:input];
        [session addOutput:output];
    }else{
        return;
    }
    // 3.1 设置二维码可以识别的码制
    // 设置输出的元数据的类型，必须要在输出添加到会话之后，否则会崩溃
    // output.availableMetadataObjectTypes 或者 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 3.2添加视频预览图层(让用户可以看到界面）
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.frame = self.view.layer.bounds;
//    [self.view.layer addSublayer:layer];
    [self.view.layer insertSublayer:layer atIndex:0];
    // 4. 启动会话（让输入对象开始采集数据，输出对象开始处理数据）
    [session startRunning];
    
}

- (void)startScanAnimation{
    self.toBottom.constant = self.scanBackView.frame.size.height;
    [self.view layoutIfNeeded];
    self.toBottom.constant = 0;

    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //    [self removeScanAnimation];
    [self startScan];
}
- (void)removeScanAnimation{
    [self.chongjiboImageView.layer removeAllAnimations];
    self.chongjiboImageView.hidden = YES;
}
#pragma mark --- AVCaptureMetadataOutputObjectsDelegate ---
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"test");
}
@end
