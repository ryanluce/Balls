//
//  HelloWorldLayer.h
//  Balls
//
//  Created by Ryan Luce on 5/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "BallsModel.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    NSMutableArray *_balls;
    float _floatCurrentTime;
    BallsModel *model;
    
}

@property (nonatomic, retain) NSMutableArray *balls;
@property float floatCurrentTime;
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void) addBallAtRandomLocation;

@end
