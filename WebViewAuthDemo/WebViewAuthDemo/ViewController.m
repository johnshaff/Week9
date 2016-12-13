//
//  ViewController.m
//  WebViewAuthDemo
//
//  Created by John Shaff on 12/13/16.
//  Copyright © 2016 John Shaff. All rights reserved.
//

#import "ViewController.h"

@import WebKit;

NSString *kBaseURL =@"https://stackexchange.com/oauth/dialog";
NSString *kClientID =@"8612";
NSString *kRedirectURI =@"https://stackexchange.com/oauth/login_success";


@interface ViewController () <WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Create and Store
    WKWebView *webView = [[WKWebView alloc]init];
    
    //Create the visual
    webView.frame = self.view.frame;
    
    //Place the stuff
    [self.view addSubview:webView];
    
    webView.navigationDelegate = self;

    NSURL *authURL = [self createStackOverflowAuthURL];
    
    [webView loadRequest:[NSURLRequest requestWithURL:authURL]];
    
    
    NSOperationQueue *imageQueue = [[NSOperationQueue alloc]init];
    [imageQueue addOperationWithBlock:^{
        //gonna happen on imagequeue
        //do
        //some
        //stuff
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            //ui stuff addeded to the main queue
        }];
    }];
    
    
    dispatch_queue_t imageDispatchQueue = dispatch_queue_create("imageQueue", nil);
    dispatch_async(imageDispatchQueue, ^{
        //gonna happen on imagequeue
        //do
        //some
        //stuff
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //ui stuff addeded to the main queue
        });
    });
 }


-(NSURL *)createStackOverflowAuthURL {
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&redicrect_uri=%@",
                           kBaseURL,
                           kClientID,
                           kRedirectURI];
    
    return [[NSURL alloc]initWithString:urlString];
}



-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if ([navigationAction.request.URL.path isEqualToString:@"oauth/login_success"]) {
        NSLog(@"IS TOKEN IN STRING? : %@", navigationAction.request.URL.absoluteString);
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
}

@end
