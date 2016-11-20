//
//  ViewController.m
//  JailbreakDetection
//
//  Created by Augusta Bogie on 2/13/16.
//  Copyright © 2016 Augusta Bogie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLConnectionDataDelegate>
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) UITextView *textOutput;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)checkSSLPinning:(id)sender
{
    NSLog(@"CHECK");
    
    NSURL *httpsURL = [NSURL URLWithString:@"https://masbog.com/ping.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:httpsURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.0f];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];
    
    if ([self isSSLPinning]) {
        [self printMessage:@"Making pinned request"];
    }
    else {
        [self printMessage:@"Making non-pinned request"];
    }
    
    if ([self.view.subviews containsObject:self.textOutput]) {
        [self.textOutput removeFromSuperview];
    }
    
    self.textOutput = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.center.y/2+250, self.view.frame.size.width, self.view.frame.size.height/2-100)];
    self.textOutput.scrollEnabled = YES;
    [self.view addSubview:self.textOutput];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    NSData *masbogCertData = [self masbogCert];
    
    if ([remoteCertificateData isEqualToData:masbogCertData] || [self isSSLPinning] == NO) {
        
        if ([self isSSLPinning] || [remoteCertificateData isEqualToData:masbogCertData]) {
            [self printMessage:@"The server's certificate is the valid masbog.com certificate. Allowing the request."];
        }
        else {
            [self printMessage:@"The server's certificate does not match masbog.com Continuing anyway."];
        }
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        [self printMessage:@"The server's certificate does not match masbog.com Canceling the request."];
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.responseData == nil) {
        self.responseData = [NSMutableData dataWithData:data];
    }
    else {
        [self.responseData appendData:data];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    [self printMessage:[NSString stringWithFormat:@"Your IP Address is : %@", response]];
    self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self printMessage:[NSString stringWithFormat:@"ERROR : %@", error.localizedDescription]];
}

- (NSData *)masbogCert
{
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"masbog.com" ofType:@"der"];
    return [NSData dataWithContentsOfFile:cerPath];
}


- (void)printMessage:(NSString *)message
{
    NSString *existingMessage = self.textOutput.text;
    self.textOutput.text = [existingMessage stringByAppendingFormat:@"\n%@", message];
    NSLog(@"%@", message);
}


- (BOOL)isSSLPinning
{
    NSString *envValue = [[[NSProcessInfo processInfo] environment] objectForKey:@"SSL_PINNING"];
    return [envValue boolValue];
}

@end
