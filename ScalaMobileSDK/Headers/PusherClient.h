//
//  PusherClient.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PusherChannel.h"

@protocol PusherClientDelegate;

@interface PusherClient : NSObject

@property (nonatomic, strong, readonly) NSString *socketID;
@property (nonatomic, weak, readonly) id<PusherClientDelegate> delegate;
@property (nonatomic, assign) BOOL automaticallyReconnect; // Default is YES

#if TARGET_OS_IPHONE
@property (nonatomic, assign) BOOL automaticallyDisconnectInBackground; // Default is YES
#endif

// Bully Version
+ (NSString *)version;

// Initializer
- (id)initWithAppKey:(NSString *)appKey andPusherSite:(NSString *) pusheSite delegate:(id<PusherClientDelegate>)delegate;

// Subscribing
- (PusherChannel *)subscribeToChannelWithName:(NSString *)channelName;
- (PusherChannel *)subscribeToChannelWithName:(NSString *)channelName authenticationBlock:(PusherChannelAuthenticationBlock)authenticationBlock;

// Managing the Connection
- (void)connect;
- (void)disconnect;
- (BOOL)isConnected;

@end


@protocol PusherClientDelegate <NSObject>

@optional

- (void)pusherClientDidConnect:(PusherClient *)client;
- (void)pusherClient:(PusherClient *)client didReceiveError:(NSError *)error;
- (void)pusherClientDidDisconnect:(PusherClient *)client;

@end
