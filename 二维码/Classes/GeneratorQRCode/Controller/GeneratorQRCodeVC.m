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
@property (weak, nonatomic) IBOutlet UIButton *centerImageBtn;
@property (nonatomic, strong) UIImage *centerImage;

@end

@implementation GeneratorQRCodeVC
- (void)viewDidLoad{
    [super viewDidLoad];

}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.inputTV endEditing:YES];
    NSString *inputString = self.inputTV.text ? self.inputTV.text: @"";
    self.qrCodeImageView.image = [QRCodeTool generatorQRCode:inputString centerImage:self.centerImage];
    
}
- (IBAction)changeCenterImage:(UIButton*)btn {
    btn.selected = !btn.selected;
    if (btn.selected == YES) {
        self.centerImage = [UIImage imageNamed:@"lingling.png"];
    }else{
        self.centerImage = [UIImage imageNamed:@"me.png"];
    }
}

@end
