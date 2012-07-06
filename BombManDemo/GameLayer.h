//
//  GameLayer.h
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    CCTMXLayer *_level1; //Bombable, pushable
    CCTMXLayer *_level2; //Collidable
    CCTMXLayer *_level3; //Collidable, Bombable
    CCTMXLayer *_level4; //Hideable
    CCSprite *_player;
    NSMutableArray *_enemies;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *level1;
@property (nonatomic, retain) CCTMXLayer *level2;
@property (nonatomic, retain) CCTMXLayer *level3;
@property (nonatomic, retain) CCTMXLayer *level4;
@property (nonatomic, retain) CCSprite *player;
@property (nonatomic, retain) NSMutableArray *enemies;
@end
