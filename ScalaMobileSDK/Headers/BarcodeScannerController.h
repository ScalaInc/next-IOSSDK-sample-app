//
//  BarcodeScannerController.h
//  NextAdmin
//
//  Created by Wenyao Hu on 9/16/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"
@class BarcodeScannerController;
@protocol BarcodeScannerControllerDelegate <NSObject>

-(void) scannerController:(BarcodeScannerController *)scannerController didGetBarcode:(NSString*) results forCallbackId:(int)callbackId;

@end


@interface BarcodeScannerController : NSObject <ZBarReaderDelegate>

@property(nonatomic, retain) ZBarReaderViewController *reader;
@property(nonatomic, assign)id<BarcodeScannerControllerDelegate> delegate;

-(void) scanBarcode:(UIViewController*) parentViewController forCallbackId:(int)callbackId;

@end
