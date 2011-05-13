//
//  BallsModel.m
//  Balls
//
//  Created by Ryan Luce on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BallsModel.h"

#define PTM_RATIO 32

static BallsModel *sharedInstance = nil;



@implementation BallsModel

@synthesize floatCurrentTime = _floatCurrentTime, world = _world, groundBody = _groundBody;

+ (id)sharedInstance
{
    if(sharedInstance == nil)
        sharedInstance = [[BallsModel alloc] init];
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.floatCurrentTime = 0;
        [self createWorld];
    }
    return self;
}

- (void)createWorld {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
    
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, 0.0f);
    
    self.world = new b2World(gravity, true);
    
    //[self setWorld:
    
    self.world->SetContinuousPhysics(true);
    

    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    self.groundBody = self.world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;		
    
    // bottom
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
    self.groundBody->CreateFixture(&groundBox,0);
    
    // top
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
    self.groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
    self.groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
    self.groundBody->CreateFixture(&groundBox,0);
}

- (void)destroyWorld {
	//[self unschedule:@selector(step:)];
	delete _world;
	_world = NULL;
}




@end
