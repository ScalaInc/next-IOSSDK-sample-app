//
//  PusherController.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PusherChannel.h"
#import "PusherClient.h"
@class PusherController;
@protocol PusherControllerDelegate <NSObject>

-(void) didReceivePusherEvent:(NSDictionary*) pusherData;

@end

@interface PusherController : NSObject <PusherClientDelegate>
@property(nonatomic, assign)id<PusherControllerDelegate> delegate;

- (id) initWithAccountChannel:(NSString*) accountUuid playerChannel:(NSString* ) playerUuid appKey:(NSString*) pusherAppKey pusherSite:(NSString*) pusherSite appId:(NSString*) pusherAppId appSecret:(NSString*) pusherAppSecret;
- (void) registerPusherEvent:(NSString*) eventName andNodeType:(NSString*) nodeType withChannel:(NSString*) channelName;
- (void)triggerEvent:(NSString *)eventName onChannel:(NSString *)channelName data:(NSData* )bodyData;
@end
