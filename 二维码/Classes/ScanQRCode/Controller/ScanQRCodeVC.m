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

@interface ScanQRCodeVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toBottom;
@property (weak, nonatomic) IBOutlet UIView *scanBackView;
@property (weak, nonatomic) IBOutlet UIImageView *chongjiboImageView;

@end

@implementation ScanQRCodeVC

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self startScanAnimation];
    [self startScan];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self removeScanAnimation];
}
- (void)startScan{
    [[QRCodeTool sharedQRCodeTool] scanQRCode:self.view isDrawQRCodeFrame:YES interestRect:self.scanBackView.frame completion:^(NSArray *resultStrs) {
        NSLog(@"%@", resultStrs);
    }];
}

- (void)startScanAnimation{
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
