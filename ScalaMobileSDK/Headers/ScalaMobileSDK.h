//
//  ScalaMobileSDK.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconController.h"
#import "BeaconTransmitter.h"
#import "PusherController.h"
#import "DataHelper.h"
#import "BeaconHelper.h"
#import "PusherHelper.h"
#import "BarcodeScannerController.h"
#import "Reachability.h"
#import "CameraController.h"

@class ScalaMobileSDK;
@protocol ScalaMobileSDKDelegate <NSObject>

-(void) didGetReturnResults:(NSString*) returnString forCallbackId:(int) callbackId;
-(void) didGetNodeChangePusherEvent:(NSDictionary*)pusherData;
-(void) didGetApplicationChangePusherEvent:(NSDictionary*)pusherData;
-(void) didGetRefreshCacheRequest;
-(void) didGetNewClosestBeacon:(NSString*) returnString withType:(NSString*) type;
-(void) didGetInternetConnection;
-(void) didLoseInternetConnection;
-(void) didGetPicture:(NSData*) pictureData forCallbackId:(int) callbackId;
@end

@interface ScalaMobileSDK : NSObject <BeaconControllerDelegate, BeaconHelperDelegate, DataHelperDelegate, PusherHelperDelegate, BarcodeScannerControllerDelegate, CameraControllerDelegate>
@property(nonatomic, assign)id<ScalaMobileSDKDelegate> delegate;
@property(nonatomic,retain) UIViewController *parentViewController;

@property(strong, retain) NSString *applicationUrl;
@property(strong, retain) NSString *deviceToken;
@property BOOL landscapeOrientation;
@property BOOL scrollable;

-(void) transmitBeaconWithMajor:(NSString*) major andMinor:(NSString*) minor;
-(void) registerPusherEvent:(NSString*) eventName andNodeType:(NSString*) nodeType withChannel:(NSString *)channelName;
-(void) registerMobileDeviceWithDeviceToken:(NSString*) deviceToken andAdvertisingIdentifier:(NSString*) advertisingIdentifier;
-(void) triggerEvent:(NSString *)eventName onChannel:(NSString *)channelName data:(NSString* )eventData;
-(void) log:(NSDictionary*) logFields;
-(NSDictionary*) getNodeDataWithUUID:(NSString*) uuid withAssociations:(Boolean)withAssociations;
-(NSArray*) getBeaconArray;
-(NSArray*) getCustomerArray:(NSInteger) withDesiredProximity;
-(NSArray*) getBeaconArrayWithType:(NSString*) beaconTypes;

-(NSDictionary*) getClosestBeaconWithType:(NSString*) beaconTypes;
-(NSDictionary*) getNodeDataWithUuidList:(NSString *)uuidList withAssociations:(Boolean)withAssociations;
-(NSDictionary*) getAppInfo;

-(void) scanBarcode:(int)callbackId;
-(void) sendHttpRequest:(NSDictionary*) argument forCallbackId:(int)callbackId;
-(void) setClientInfo:(NSDictionary*) argument;
-(void) getClosestLocation;
-(void) getClosestPlayer;
-(BOOL) currentNetworkStatus;
-(BOOL) isInsideRegion:(NSDictionary*) argumentNode;
-(void) setUserInfo:(NSDictionary*) userInfo;
-(void) takePicture:(NSDictionary*) argument forCallbackId:(int)callbackId;
+(BOOL) networkStatus;
@end
