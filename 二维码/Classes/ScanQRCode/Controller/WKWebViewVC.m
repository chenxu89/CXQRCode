//
//  WKWebViewVC.m
//  二维码
//
//  Created by chenxu on 16/9/7.
//  Copyright © 2016年 chenxu. All rights reserved.
//

#import "WKWebViewVC.h"
#import <WebKit/WebKit.h>

@interface WKWebViewVC ()
@property (weak, nonatomic) UITextView *textView;
@property (nonatomic, weak) WKWebView *webView;
@end

@implementation WKWebViewVC

- (UITextView *)textView{
    if (!_textView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.frame = self.view.bounds;
        textView.userInteractionEnabled = NO;
        textView.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:textView];
        _textView = textView;
    }
    return _textView;
}

- (WKWebView *)webView{
    if (!_webView) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:webView];
        _webView = webView;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setResultStr:(NSString *)resultStr{
    _resultStr = resultStr;
    
    NSURL *url = [NSURL URLWithString:resultStr];
    BOOL can = [[UIApplication sharedApplication] canOpenURL:url];
    if (can) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }else{
        self.textView.text = resultStr;
    }
}

- (void)dealloc{
//    NSLog(@"%s", __func__);
}
@end
