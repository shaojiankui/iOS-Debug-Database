//
//  ViewController.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "ViewController.h"
#import "SFDebugDB.h"
@interface ViewController ()<UIWebViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)refreshTouched:(UIButton*)sender {
   [sender setTitle:[SFDebugDB shared].address forState:UIControlStateNormal];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

}
@end
