//
//  CameraController.h
//  ScalaMobileSDKIOS
//
//  Created by Wenyao Hu on 1/8/15.
//  Copyright (c) 2015 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@class CameraController;
@protocol CameraControllerDelegate <NSObject>

-(void) didGetPicture:(NSString*)returnString forCallbackId:(int)callbackId;

@end
@interface CameraController : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, retain) UIImagePickerController *picker;
@property(nonatomic, assign)id<CameraControllerDelegate> delegate;

-(void) takePicture:(UIViewController*) parentViewController fromSource:(NSString*) source forCallbackId:(int)callbackId;
@end
