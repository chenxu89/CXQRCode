//
//  GeneratorQRCodeVC.m
//  二维码
//
//  Created by chenxu on 16/9/5.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "GeneratorQRCodeVC.h"
#import "QRCodeTool.h"

@interface GeneratorQRCodeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UITextView *inputTV;

@end

@implementation GeneratorQRCodeVC
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.inputTV endEditing:YES];
    NSString *inputString = self.inputTV.text ? self.inputTV.text: @"";
    UIImage *centerImage = [UIImage imageNamed:@"erha.png"];
    self.qrCodeImageView.image = [QRCodeTool generatorQRCode:inputString centerImage:centerImage];
    
}

@end
