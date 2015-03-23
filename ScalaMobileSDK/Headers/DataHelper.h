//
//  DataHelper.h
//  ScalaMobileSDKIOS
//
//  Created by Wenyao Hu on 10/13/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class DataHelper;
@protocol DataHelperDelegate <NSObject>

-(void) didGetData:(NSDictionary*) nodeData;
-(void) didRetrieveBeaconInfo:(NSDictionary*)beaconNodeData forRequestedBeacons:(NSMutableArray*) requestedBeacons;
-(void) didRetrieveNodes:(NSArray *) retrievedNodes forUuidList:(NSString*) uuidList andDepth:(int) depth refreshOption:(BOOL) refresh forFunction:(NSString*) function;
-(void) didRetrieveNode:(NSDictionary *) retrievedNode forUuid:(NSString*) uuid andDepth:(int) depth refreshOption:(BOOL) refresh forFunction:(NSString*) function;
-(void) didSetCustomer:(NSDictionary*) customer forIdentifier:(NSString*) identifier;
-(void) didSendHttpRequest:(NSDictionary*) returnedData forCallbackId:(int)callbackId;
@end

@interface DataHelper : NSObject
@property(nonatomic, assign) id <DataHelperDelegate> delegate;
@property(nonatomic, retain) NSString* accessToken;
@property(nonatomic, retain) NSString* accountUuid;
@property(nonatomic, retain) NSString* apiSite;

-(id) initWithAccessToken:(NSString*) accessToken andApiSite:(NSString*) apiSite;
-(NSDictionary*) getAPICallResults:(NSString*) restCallString;
-(NSDictionary*) registerMobileDeviceWithDeviceToken:(NSString*) deviceToken andAdvertisingIdentifier:(NSString*) advertisingIdentifier;
-(void) retrieveBeaconInfo:(NSMutableArray*) requestedBeacons;
-(void) retrieveNodeWithUUIDList:(NSString*) uuidList andDepth:(int) depth refreshOption:(BOOL) refresh forFunction:(NSString*) function;
-(void) retrieveNodeWithUUID:(NSString*) uuid andDepth:(int) depth refreshOption:(BOOL) refresh forFunction:(NSString*) function;
-(void) setCustomer:(NSString *)identifier;
-(void) logMessage:(NSMutableDictionary *)logMessage;
-(void) sendHttpRequest:(NSDictionary*) argument forCallbackId:(int)callbackId;
-(void) sendPushNotification:(NSString*)notificationText forDeviceToken:(NSString*) deviceToken withLogFields:(NSMutableDictionary*) logFields;
-(NSDictionary*) getElasticsearchDocument:(NSDictionary*) searchFilters;
@end
