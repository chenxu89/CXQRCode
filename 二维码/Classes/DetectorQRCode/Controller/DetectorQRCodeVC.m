//
//  DetectorQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "DetectorQRCodeVC.h"
#import "QRCodeTool.h"

@interface DetectorQRCodeVC ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *souceImageView;

@property (nonatomic, strong) UIImage *souceImage;

@end

@implementation DetectorQRCodeVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.souceImage = self.souceImageView.image;
    
    // 添加长按手势识别二维码
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    [self.souceImageView addGestureRecognizer:gesture];
    self.souceImageView.userInteractionEnabled = YES;
}
//恢复到原始图片
- (IBAction)reset {
    self.souceImageView.image = self.souceImage;
}
- (void)longTapAction:(UILongPressGestureRecognizer *)longPress{
    //长按手势添加后总是调用两次的方法处理
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self detectQRCode];
    }
}
- (IBAction)detectQRCode
{
    NSDictionary *dic = [QRCodeTool detectorQRCodeImage:self.souceImageView.image isDrawQRCodeFrame:YES];
    NSArray *result = dic[@"strArray"];
    self.souceImageView.image = dic[@"resultImage"];
//    NSLog(@"%@", result);
    // 将识别的文字弹窗显示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:result.description delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
    }
}
@end
