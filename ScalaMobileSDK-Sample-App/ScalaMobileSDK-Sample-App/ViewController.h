//
//  ViewController.h
//  ScalaMobileSDK-Sample-App
//
//  Created by Wenyao Hu on 3/23/15.
//  Copyright (c) 2015 scala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScalaMobileSDK.h"

@interface ViewController : UIViewController <UIWebViewDelegate, ScalaMobileSDKDelegate>{
    ScalaMobileSDK *scala;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *frontView;
@property (nonatomic, retain) NSString* major;
@property (nonatomic, retain) NSString* minor;
@end

