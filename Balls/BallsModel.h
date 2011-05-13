//
//  BallsModel.h
//  Balls
//
//  Created by Ryan Luce on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface BallsModel : NSObject {
    float _floatCurrentTime;
    b2World *_world;
    b2Body *_groundBody;
}

+ (id)sharedInstance;

@property float floatCurrentTime;

@property (readwrite) b2World *world;
@property (readwrite) b2Body *groundBody;

- (void)createWorld;
- (void)destroyWorld;

@end
