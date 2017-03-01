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
//    NSString *path = [NSString stringWithFormat:@"http://%@:%zd",[SFDebugDB shared].host,[SFDebugDB shared].port];
//    
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)refreshTouched:(id)sender {
//    NSString *path = [NSString stringWithFormat:@"http://127.0.0.1:%zd",[SFDebugDB shared].port];
//    
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

}
@end
