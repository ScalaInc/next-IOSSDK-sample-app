//
//  PusherChannel.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PusherClient;
@class PusherChannel;

typedef void (^PusherChannelEventBlock)(id message);
typedef void (^PusherChannelAuthenticationBlock)(PusherChannel *channel);

@interface PusherChannel : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, weak, readonly) PusherClient *client;
@property (nonatomic, copy) PusherChannelAuthenticationBlock authenticationBlock;
@property (nonatomic, strong, readonly) NSDictionary *authenticationParameters;
@property (nonatomic, strong, readonly) NSData *authenticationParametersData;

- (BOOL)isPrivate;

- (void)bindToEvent:(NSString *)eventName block:(PusherChannelEventBlock)block;
- (void)unbindEvent:(NSString *)eventName;

- (void)subscribeWithAuthentication:(NSDictionary *)authentication;
- (void)unsubscribe;

@end