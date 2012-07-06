//
//  GameLayer.m
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"

@interface GameLayer (Private)

-(void)setViewpointCenter:(CGPoint) position;

@end
@implementation GameLayer

@synthesize background = _background;
@synthesize level1 = _level1;
@synthesize level2 = _level2;
@synthesize level3 = _level3;
@synthesize level4 = _level4;
@synthesize tileMap = _tileMap;
@synthesize player = _player;
@synthesize enemies = _enemies;


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        self.enemies = [[[NSMutableArray alloc]init]autorelease];
        
//        [self schedule:@selector(testCollisions:)];
        
        self.isTouchEnabled = YES;
        
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"game_background.tmx"];
        self.background = [_tileMap layerNamed:@"background"];
        self.level1 = [_tileMap layerNamed:@"level1"];
        self.level2 = [_tileMap layerNamed:@"level2"];
        self.level3 = [_tileMap layerNamed:@"level3"];
        self.level4 = [_tileMap layerNamed:@"level4"];


        
        [self addChild:_tileMap z:-1];

    
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *player = [objects objectNamed:@"player"]; 
        NSAssert(player != nil, @"SpawnPoint object not found");
        int x = [[player valueForKey:@"x"] intValue];
        int y = [[player valueForKey:@"y"] intValue];
        
        self.player = [CCSprite spriteWithFile:@"unit_bazzi02.png"];
        _player.position = ccp(x, y);
        [self addChild:_player]; 
        
        [self setViewpointCenter:[_player position]];
    }
    return self;
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width /2);
    int y = MAX(position.y, winSize.height /2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) 
            - winSize.width /2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) 
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
    
}

-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                     priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(void)setPlayerPosition:(CGPoint)position {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    int tileGid = [_level2 tileGIDAt:tileCoord];
    if (!tileGid) {
        tileGid = [_level3 tileGIDAt:tileCoord];
    }
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                return;
            }
//            NSString *collectable = [properties valueForKey:@"Collectable"];
//            if (collectable && [collectable compare:@"True"] == NSOrderedSame) {
//                [_meta removeTileAt:tileCoord];
//                [_foreground removeTileAt:tileCoord];
//                self.numCollected++;
//                
//                CCLabelTTF *label = (CCLabelTTF *)[self.parent getChildByTag:100];
//                [label setString:[NSString stringWithFormat:@"%d", self.numCollected]];
//                [[SimpleAudioEngine sharedEngine] playEffect:@"pickup.caf"];
//            }
        }
    }
    _player.position = position;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
        // old contents of ccTouchEnded:withEvent:
        
        CGPoint touchLocation = [touch locationInView: [touch view]]; 
        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];
        
        CGPoint playerPos = _player.position;
        CGPoint diff = ccpSub(touchLocation, playerPos);
        if (abs(diff.x) > abs(diff.y)) {
            if (diff.x >0) {
                playerPos.x += _tileMap.tileSize.width;
            } else {
                playerPos.x -= _tileMap.tileSize.width; 
            } 
        } else {
            if (diff.y >0) {
                playerPos.y += _tileMap.tileSize.height;
            } else {
                playerPos.y -= _tileMap.tileSize.height;
            }
        }
        
        if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
            playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
            playerPos.y >=0&&
            playerPos.x >=0 ) 
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"move.caf"];
            [self setPlayerPosition:playerPos];
        }
        
        [self setViewpointCenter:_player.position];
    
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    self.tileMap = nil;
    self.background = nil;
    self.level1 = nil;
    self.level2 = nil;
    self.level3 = nil;
    self.level4 = nil;
    self.player = nil;
    self.enemies = nil;
}

@end
