//
//  ScanQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "ScanQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeTool.h"
#import "WKWebViewVC.h"

@interface ScanQRCodeVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toBottom;
@property (weak, nonatomic) IBOutlet UIView *scanBackView;
@property (weak, nonatomic) IBOutlet UIImageView *chongjiboImageView;
@end

@implementation ScanQRCodeVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startScan];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
//    [self stopScan];
}
- (void)startScan{
    [[QRCodeTool sharedQRCodeTool] scanQRCode:self.view isDrawQRCodeFrame:NO interestRect:self.scanBackView.frame completion:^(NSArray *resultStrs) {
        NSLog(@"%@", resultStrs);
        if (resultStrs.count <= 0) {
            return;
        }
        //打开网页
        WKWebViewVC *webViewVC = [[WKWebViewVC alloc] initWithNibName:@"WKWebViewVC" bundle:nil];
        webViewVC.resultStr = resultStrs.firstObject;
        [self.navigationController pushViewController:webViewVC animated:YES];
        
        //停止扫描
        [self stopScan];
    }];
    
    [self startScanAnimation];
}

- (void)stopScan{
    [[QRCodeTool sharedQRCodeTool] stopScanQRCode];
    [self removeScanAnimation];
}

- (void)startScanAnimation{
    self.chongjiboImageView.hidden = NO;
    self.toBottom.constant = self.scanBackView.frame.size.height;
    [self.view layoutIfNeeded];
    self.toBottom.constant = 0;

    [UIView animateWithDuration:1.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self removeScanAnimation];
//    [self startScan];
}
- (void)removeScanAnimation{
    [self.chongjiboImageView.layer removeAllAnimations];
    self.chongjiboImageView.hidden = YES;
}

- (void)dealloc{
//    NSLog(@"%s",__func__);
}

@end
