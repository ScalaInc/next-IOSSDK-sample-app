//
//  PusherChannelPrivate.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PusherChannel.h"

@interface PusherChannelPrivate : NSObject

@end

@class PusherClient;

@interface PusherChannel ()

@property (nonatomic, weak, readwrite) PusherClient *client;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *subscriptions;

- (id)_initWithName:(NSString *)name client:(PusherClient *)client authenticationBlock:(PusherChannelAuthenticationBlock)authenticationBlock;
- (void)_subscribe;

@end