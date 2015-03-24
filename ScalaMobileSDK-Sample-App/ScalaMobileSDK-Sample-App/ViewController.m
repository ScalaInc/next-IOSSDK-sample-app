//
//  ViewController.m
//  ScalaMobileSDK-Sample-App
//
//  Created by Wenyao Hu on 3/23/15.
//  Copyright (c) 2015 scala. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <AdSupport/AdSupport.h>

@interface ViewController () {
    BOOL _landscape;
    NSString *model;
    BOOL webViewDisplayed;
    NSString *loadedUrl;
    NSDictionary* mainAppInfo;
    NSString* mainAppUuid;
    #ifdef DEBUG
    #   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    #else
    #   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    #endif
}

@property (nonatomic, strong) NSArray *priorConstraints;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.frontView];
    webViewDisplayed = NO;
    // since frontView has no constraints set to match it's superview, we set them here
    _priorConstraints = [self constrainSubview:self.frontView toMatchWithSuperview:self.view];
    
    
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.userInteractionEnabled = YES;
    
    scala = [[ScalaMobileSDK alloc] init];
    scala.delegate = self;
    scala.parentViewController = self;
    [self loadWebView];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleApplicationNotification:)
     name:@"ApplicationEvent"
     object:nil];
}


-(void) loadWebView {
    if([scala currentNetworkStatus]){
        DLog(@"loading url: %@", scala.applicationUrl);
        
        if(scala.applicationUrl != nil) {
            NSString *fullURL = scala.applicationUrl;
            NSURL *url = [NSURL URLWithString:fullURL];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            
            if (requestObj){
                [[NSURLCache sharedURLCache] removeCachedResponseForRequest:requestObj];
                [[NSURLCache sharedURLCache] removeAllCachedResponses];
            }
            
            [self.webView sizeToFit];
            [self.webView loadRequest:requestObj];
            self.webView.scrollView.scrollEnabled = scala.scrollable;
            
            if([fullURL rangeOfString:@"initializer"].location != NSNotFound){
                webViewDisplayed = NO;
                [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
                webViewDisplayed = YES;
            }
            loadedUrl = scala.applicationUrl;
        }
    }
}

// handle notification from application
-(void)handleApplicationNotification:(NSNotification *)pNotification {
    NSString* appEvent = [pNotification object];
    if([appEvent isEqualToString:@"ApplicationWillTerminate"]) {
        DLog(@"application will terminate");
        [self.webView loadHTMLString:@"" baseURL:nil];
        
        [self.webView stopLoading];
        
        [self.webView setDelegate:nil];
        [self.webView removeFromSuperview];
    }
}

- (NSArray *)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[subview]|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|[subview]|"
                    options:0
                    metrics:nil
                    views:viewsDictionary]];
    [superview addConstraints:constraints];
    
    return constraints;
}

- (void)performTransition:(UIViewAnimationOptions)options
{
    
    UIView *fromView, *toView;
    
    BOOL currentLandscape = NO;
    
    if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
        currentLandscape = YES;
    }
    
    
    if ([self.frontView superview] != nil) {
        fromView = self.frontView;
        toView = self.webView;
        if(scala.landscapeOrientation){
            _landscape = YES;
            
            // if the current device orientation is already landscape, set orientation to landscape again doesn't do anything.
            // work around: set to portrait mode first, then set orientation to landscape.
            if(currentLandscape) {
                [[UIDevice currentDevice] setValue:
                 [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                            forKey:@"orientation"];
            }
            [[UIDevice currentDevice] setValue:
             [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight]
                                        forKey:@"orientation"];
        } else {
            _landscape = NO;
            [[UIDevice currentDevice] setValue:
             [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                        forKey:@"orientation"];
        }
        
        self.webView.scrollView.scrollEnabled = scala.scrollable;
    } else {
        fromView = self.webView;
        toView = self.frontView;
    }
    
    NSArray *priorConstraints = self.priorConstraints;
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:options
                    completion:^(BOOL finished) {
                        // animation completed
                        if (priorConstraints != nil) {
                            [self.view removeConstraints:priorConstraints];
                        }
                    }];
    _priorConstraints = [self constrainSubview:toView toMatchWithSuperview:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)returnResult:(int)callbackId args:(id)arg, ...; {
    DLog(@"RETURNING TO '%d'", callbackId);
    if (callbackId==0) return;
    
    va_list argsList;
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    if(arg != nil){
        [resultArray addObject:arg];
        va_start(argsList, arg);
        while((arg = va_arg(argsList, id)) != nil)
            [resultArray addObject:arg];
        va_end(argsList);
    }
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *resultArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self returnResultAfterDelay:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,resultArrayString]];
}

-(void)returnResultAfterDelay:(NSString*)str {
    DLog(@"************************************returnResultAfterDelay");
    // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = [[request URL] absoluteString];
    DLog(@"************************************loading: %@", requestString);
    
    if ([requestString hasPrefix:@"js-frame:"]) {
        DLog(@"beacon request");
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
        int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSData* data = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSArray *args = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        
        [self handleCall:function callbackId:callbackId args:args];
        return NO;
    }
    
    return YES;
}

// Implements all you native function in this one, by matching 'functionName' and parsing 'args'
// Use 'callbackId' with 'returnResult' selector when you get some results to send back to javascript
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
    if ([functionName isEqualToString:@"getBeacons"]) {
        
        // return all beacon information including in-associated nodes.
        NSString *returnString = @"{\"beacons\":";
        NSArray* beaconArray = [scala getBeaconArray];
        NSError *writeError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:beaconArray options:NSJSONWritingPrettyPrinted error:&writeError];
        returnString = [NSString stringWithFormat:@"%@%@", returnString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        returnString = [NSString stringWithFormat:@"%@%@", returnString, @"}" ];
        DLog(@"return string: %@", returnString);
        
        [self returnResult:callbackId args:returnString,nil];
        
    } else if ([functionName isEqualToString:@"getDeviceInfo"]) {
        
        NSString *token = scala.deviceToken;
        NSString *advertisingIdentifier = [self advertisingIdentifier];
        NSString *returnString;
        returnString = [NSString stringWithFormat:@"%@%@%@%@%@", @"{\"deviceToken\":\"" , token , @"\",\"advertisingIdentifier\":\"" , advertisingIdentifier, @"\"}"];
        
        DLog(@"return string: %@", returnString);
        [scala registerMobileDeviceWithDeviceToken:token andAdvertisingIdentifier:advertisingIdentifier];
        [self returnResult:callbackId args:returnString,nil];
        
    } else if ([functionName isEqualToString:@"setBeaconMM"]) {
        self.major = args[0];
        self.minor = args[1];
        
        DLog(@"setting device major/minor %@ : %@",args[0],args[1]);
        [scala transmitBeaconWithMajor:self.major andMinor:self.minor];
        
    } else if ([functionName isEqualToString:@"getClosestBeaconWithType"]) {
        // return all beacon information including in-associated nodes.
        NSTimeInterval startTime = CACurrentMediaTime();
        NSString* beaconTypes = args[0];
        NSDictionary* closestBeaconNode = [scala getClosestBeaconWithType:beaconTypes];
        
        NSString *returnString = @"";
        if(closestBeaconNode != nil){
            NSError *writeError = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:closestBeaconNode options:NSJSONWritingPrettyPrinted error:&writeError];
            returnString = [NSString stringWithFormat:@"%@%@", returnString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } else {
            returnString = @"(null)";
        }
        CFTimeInterval runningTime = CACurrentMediaTime() - startTime;
        DLog(@"getClosestBeaconWithType: %@  -- Return string: %@", beaconTypes, returnString);
        DLog(@"========================= getClosestBeaconWithType takes %f seconds", runningTime);
        [self returnResult:callbackId args:returnString,nil];
        
    } else if ([functionName isEqualToString:@"getNodeDataWithUuidList"]){
        // return node data.
        NSTimeInterval startTime = CACurrentMediaTime();
        NSString* uuids = args[0];
        DLog(@"getNodeDataWithUuidList: %@ for call back id: %d", uuids, callbackId);
        NSString* withAssociation = args[1];
        Boolean withAssoc = [withAssociation boolValue];
        
        NSString *returnString=@"";
        NSDictionary* nodeList = [scala getNodeDataWithUuidList:uuids withAssociations:withAssoc];
        if([[nodeList allValues] count] > 0) {
            NSError *writeError = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:nodeList options:NSJSONWritingPrettyPrinted error:&writeError];
            returnString = [NSString stringWithFormat:@"%@%@", returnString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } else {
            returnString = @"(null)";
        }
        
        NSArray* returnedUuids = [nodeList allKeys];
        NSArray* requestUuids = [uuids componentsSeparatedByString:@","];
        NSMutableArray* missingUuids = [[NSMutableArray alloc]init];
        for(NSString* uuid in requestUuids){
            if(![returnedUuids containsObject:uuid]){
                [missingUuids addObject:uuid];
            }
        }
        CFTimeInterval runningTime = CACurrentMediaTime() - startTime;
        DLog(@"getNodeDataWithUuidList %@  -- Return string: %@", uuids, returnString);
        DLog(@"========================= getNodeDataWithUuidList takes %f seconds", runningTime);
        [self returnResult:callbackId args:returnString,nil];
        
    } else if ([functionName isEqualToString:@"getNodeDataWithUUID"]){
        NSTimeInterval startTime = CACurrentMediaTime();
        // return node data.
        NSString* uuid = args[0];
        DLog(@"getNodeDataWithUUID: %@", uuid);
        NSString* withAssociation = args[1];
        Boolean withAssoc = [withAssociation boolValue];
        
        NSString *returnString=@"";
        NSDictionary* nodeData = [scala getNodeDataWithUUID:uuid withAssociations:withAssoc];
        
        if(nodeData != nil){
            NSError *writeError = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:nodeData options:NSJSONWritingPrettyPrinted error:&writeError];
            returnString = [NSString stringWithFormat:@"%@%@", returnString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } else {
            returnString = @"(null)";
        }
        CFTimeInterval runningTime = CACurrentMediaTime() - startTime;
        DLog(@"getNodeDataWithUUID return string: %@", returnString);
        DLog(@"========================= getNodeDataWithUUID takes %f seconds", runningTime);
        [self returnResult:callbackId args:returnString,nil];
        
    } else if ([functionName isEqualToString:@"getCustomers"]) {
        // return all customers information
        NSInteger desiredProximity =  [args[0] integerValue];
        NSString *returnString = @"{\"customers\":";
        
        NSArray* customers = [scala getCustomerArray: desiredProximity];
        if(customers != nil){
            NSError *writeError = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:customers options:NSJSONWritingPrettyPrinted error:&writeError];
            returnString = [NSString stringWithFormat:@"%@%@", returnString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
        returnString = [NSString stringWithFormat:@"%@%@", returnString, @"}" ];
        DLog(@"return String: %@", returnString);
        [self returnResult:callbackId args:returnString,nil];
        
    } else if ([functionName isEqualToString:@"registerPusherEvent"]){
        // return node data.
        NSString* eventName = args[0];
        NSString* nodeType = args[1];
        NSString* channelName = args[2];
        NSString *returnString = @"ok";
        [scala registerPusherEvent:eventName andNodeType:nodeType withChannel:channelName];
        DLog(@"registerPusherEvent return string: %@", returnString);
        
        [self returnResult:callbackId args:returnString,nil];
    } else if ([functionName isEqualToString:@"triggerPusherEvent"]){
        // return node data.
        NSString* eventName = args[0];
        NSString* channelName = args[1];
        NSString* eventData = args[2];
        
        NSString *returnString = @"ok";
        [scala triggerEvent:eventName onChannel:channelName data:eventData];
        DLog(@"triggerPusherEvent return string: %@", returnString);
        
        [self returnResult:callbackId args:returnString,nil];
    } else if ([functionName isEqualToString:@"setDeviceOrientation"]) {
        NSString* orientation = args[0];
        if([orientation caseInsensitiveCompare:@"landscape"] == NSOrderedSame){
            _landscape = YES;
        } else {
            _landscape = NO;
        }
        
        NSString *returnString = @"ok";
        DLog(@"setDeviceOrientation return string: %@", returnString);
        
        [self returnResult:callbackId args:returnString,nil];
    } else if ([functionName isEqualToString:@"log"]) {
        NSError *error;
        NSString* argumentString = args[0];
        NSDictionary* logFields = [NSJSONSerialization JSONObjectWithData:[argumentString dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options: NSJSONReadingMutableContainers
                                                                    error: &error];
        
        [scala log:logFields];
        NSString *returnString = @"ok";
        DLog(@"log return string: %@", returnString);
        
        [self returnResult:callbackId args:returnString,nil];
    } else if ([functionName isEqualToString:@"sendHttpRequest"]) {
        NSError* error;
        NSString *argument = args[0];
        NSDictionary* argumentNode = [NSJSONSerialization JSONObjectWithData:[argument dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        [scala sendHttpRequest:argumentNode forCallbackId:callbackId];
        
    } else if ([functionName isEqualToString:@"setClientInfo"]) {
        NSError* error;
        NSString *argument = args[0];
        NSDictionary* argumentNode = [NSJSONSerialization JSONObjectWithData:[argument dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        [scala setClientInfo:argumentNode];
        if(webViewDisplayed == YES) {
            [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
            webViewDisplayed = NO;
        }
        [self returnResult:callbackId args:@"OK", nil];
        
    } else if ([functionName isEqualToString:@"fadeInWebView"]) {
        if(webViewDisplayed == NO) {
            [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
            if(scala.landscapeOrientation){
                _landscape = YES;
                [[UIDevice currentDevice] setValue:
                 [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight]
                                            forKey:@"orientation"];
            } else {
                _landscape = NO;
                [[UIDevice currentDevice] setValue:
                 [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                            forKey:@"orientation"];
            }
            
            webViewDisplayed = YES;
        }
        
        [self returnResult:callbackId args:@"OK", nil];
        
    } else if ([functionName isEqualToString:@"fadeOutWebView"]) {
        if(webViewDisplayed == YES) {
            [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
            webViewDisplayed = NO;
        }
        
        [self returnResult:callbackId args:@"OK", nil];
        
    } else if ([functionName isEqualToString:@"resend"]) {
        [scala getClosestLocation];
        [scala getClosestPlayer];
        [self returnResult:callbackId args:@"OK", nil];
        
    } else if ([functionName isEqualToString:@"scanBarcode"]) {
        [scala scanBarcode:callbackId];
        
    } else if ([functionName isEqualToString:@"getAppInfo"]) {
        NSDictionary* appInfo = [scala getAppInfo];
        NSString* returnString = @"(nul)";
        if(appInfo != nil){
            NSError *writeError = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:appInfo options:NSJSONWritingPrettyPrinted error:&writeError];
            returnString =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        DLog(@"getAppInfo return String: %@", returnString);
        [self returnResult:callbackId args:returnString,nil];
        
        
    } else if ([functionName isEqualToString:@"setUserInfo"]) {
        NSError* error;
        NSString *argument = args[0];
        NSDictionary* argumentNode = [NSJSONSerialization JSONObjectWithData:[argument dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        [scala setUserInfo:argumentNode];
        [self returnResult:callbackId args:@"OK", nil];
        
    } else if ([functionName isEqualToString:@"isInsideRegion"]) {
        NSError* error;
        NSString *argument = args[0];
        NSDictionary* argumentNode = [NSJSONSerialization JSONObjectWithData:[argument dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        BOOL isInsideRegion  = [scala isInsideRegion:argumentNode];
        
        NSString* returnString = [NSString stringWithFormat:@"%@", isInsideRegion ? @"YES" : @"NO"];
        
        [self returnResult:callbackId args:returnString, nil];
        
    } else if ([functionName isEqualToString:@"takePicture"]) {
        NSError* error;
        NSString *argument = args[0];
        NSDictionary* argumentNode = [NSJSONSerialization JSONObjectWithData:[argument dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        [scala takePicture:argumentNode forCallbackId:callbackId];
        
    } else {
        DLog(@"Unimplemented method '%@'",functionName);
    }
}

- (NSString *) advertisingIdentifier {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}


-(void) reloadUrl:(NSString*) applicationUrl {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    
    if([applicationUrl rangeOfString:@"/static/help/mobile/configure.html"].location != NSNotFound){
        if(webViewDisplayed) {
            _landscape = NO;
            [[UIDevice currentDevice] setValue:
             [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                        forKey:@"orientation"];
            [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
            webViewDisplayed = NO;
        }
    }
    if([loadedUrl isEqualToString:applicationUrl]){
        [self.webView reload];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:applicationUrl]]];
        loadedUrl = applicationUrl;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    if(_landscape){
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    // Disable user selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

#pragma - ScalaMobileSDKDelegate
-(void) didGetReturnResults:(NSString *)returnString forCallbackId:(int)callbackId {
    [self returnResult:callbackId args:returnString, nil];
}

-(void) didGetNodeChangePusherEvent:(NSDictionary*)pusherData {
    NSString* uuid = [pusherData objectForKey:@"uuid"];
    NSString* resultArrayString = [NSString stringWithFormat:@"%@%@%@", @"\"", uuid, @"\""];
    [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.nodeChange(%@);",resultArrayString] afterDelay:2.0];
}

-(void) didGetApplicationChangePusherEvent:(NSDictionary*)pusherData {
    [self reloadUrl:scala.applicationUrl];
}

-(void) didGetRefreshCacheRequest {
    [self reloadUrl:scala.applicationUrl];
    [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.refreshCache();"] afterDelay:2.0];
}

-(void) didGetNewClosestBeacon:(NSString*) returnString withType:(NSString*) type {
    if(returnString == nil) {
        returnString = @"\"(null)\"";
    }
    if([type isEqualToString:@"Location"]) {
        DLog(@"***************Location node data returned: %@ ***************", returnString);
        [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.closestLocation(%@);",returnString] afterDelay:0.0];
    } else if ([type isEqualToString:@"Player"]) {
        DLog(@"***************Player node data returned: %@ ***************", returnString);
        [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.closestPlayer(%@);",returnString] afterDelay:0.0];
    }
}

-(void) didGetInternetConnection {
    [self loadWebView];
}

-(void) didLoseInternetConnection {
    if(webViewDisplayed == YES) {
        [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
        webViewDisplayed = NO;
    }
    if([self.webView isLoading]) {
        [self.webView stopLoading];
    }
}


@end
