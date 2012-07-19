//
//  GameLayer.m
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "CCActionInstant.h"
#import "CCJoyStick.h"


enum {
	kTagSpriteSheet = 1,
};


CCSequence *seqDown;
CCSequence *seqRight;
CCSequence *seqLeft;
CCSequence *seqUp;

@interface GameLayer (Private)

-(void)setViewpointCenter:(CGPoint) position;
-(void)initAnimations;
- (void)runAnimationRight;
- (void)runAnimationDown;
-(void) callDelegate;


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
@synthesize actionArray = _actionArray;
@synthesize moveAction = _moveAction;
@synthesize walkAction = _walkAction;
@synthesize joyStick = _joyStick;


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
        
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"unit_bazzi.png"];
        
        CCSpriteBatchNode *sheet = [CCSpriteBatchNode batchNodeWithFile:@"unit_bazzi.png" capacity:10];
        //CCArray *ar=[sheet children];
        [self addChild:sheet z:0 tag:kTagSpriteSheet];
        
        
        _actionArray = [[NSMutableArray alloc] init];  
        NSMutableArray *animFrames = [NSMutableArray array];
        
        for (int i = 0; i < 3; i++) {
            
            [animFrames removeAllObjects];
                        
            for (int j = 0; j <4; j++) {
                
                CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rectInPixels:CGRectMake(i*64, j*64, 64, 64) rotated:NO offset:CGPointZero originalSize:CGSizeMake(64, 64)];
                [animFrames addObject:frame];
            }
            CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:0.2f ];
            
            CCAnimate *animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO];
            CCSequence *seq = [CCSequence actions: animate,
                               nil];
            
            if (i == 2) {
                CCSequence *seqrev= [CCSequence actions: [[animate copy] autorelease],
                                     [CCFlipX actionWithFlipX:YES],
                                     nil];
                self.moveAction = [CCRepeatForever actionWithAction: seqrev];	
                [_actionArray addObject:self.moveAction];
            }
            
            self.moveAction = [CCRepeatForever actionWithAction: seq];	
            [_actionArray addObject:self.moveAction];

        }

        
        CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rectInPixels:CGRectMake(64, 0, 64, 64) rotated:NO offset:CGPointZero originalSize:CGSizeMake(64, 64)];
        
        self.player = [CCSprite spriteWithSpriteFrame:frame1];
        
        
        [sheet addChild:_player];

        _player.position = ccp(x, y);
        

        
//        [self initAnimations];
        
        [self setViewpointCenter:[_player position]];
        
        

        

        [self schedule: @selector(refreshBackground) interval:0.5];
		
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

- (void)runAnimationRight
{
    [self.player runAction:[CCRepeatForever actionWithAction: seqRight]];
}

- (void)runAnimationDown
{
    [self.player runAction:[CCRepeatForever actionWithAction: seqDown]];
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

-(CGPoint) getPlayerPosition
{
    return _player.position;
}

-(void) playerMoveTo:(CGPoint)touchLocation
{		
//    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//    touchLocation = [self convertToNodeSpace:touchLocation];
    if (touchLocation.x < 0) {
        touchLocation.x = 0;
    }
    
    if (touchLocation.y < 0) {
        touchLocation.y = 0;
    }
    
    if (touchLocation.x > _tileMap.mapSize.width * _tileMap.tileSize.width) {
        touchLocation.x = _tileMap.mapSize.width * _tileMap.tileSize.width;
    }
    
    if (touchLocation.y > _tileMap.mapSize.height * _tileMap.tileSize.height) {
        touchLocation.y = _tileMap.mapSize.height * _tileMap.tileSize.height;
    }
    
    CGPoint moveVector = ccpSub(touchLocation, _player.position);
    
	float distanceToMove = ccpLength(moveVector);
    CGFloat moveAngle = ccpToAngle(moveVector);
    CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * moveAngle);
    
	float dragonVelocity = 480.0/3.0;
	float moveDuration = distanceToMove / dragonVelocity;
	
	cocosAngle += 46;
	if (cocosAngle < 0)
		cocosAngle += 360;
	
	int runAnim = (int)((cocosAngle)/90);
    NSLog(@"run angle11 %d", runAnim);
    if (runAnim == 0) {
        runAnim = 3;
    }
    else if (runAnim == 3) {
        runAnim = 0;
    }
    
    NSLog(@"run angle22 %d", runAnim);
    if ([_actionArray objectAtIndex:runAnim] != self.moveAction) {
        [_player stopAction:_moveAction];
        self.moveAction = [_actionArray objectAtIndex:runAnim];
        [_player runAction:_moveAction];
    }
	
	
	
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(callDelegate)];
    self.walkAction = [CCSequence actions:
                       [CCMoveTo actionWithDuration:moveDuration position:touchLocation],actionMoveDone,
                       nil
                       ];
    
    [_player runAction:_walkAction]; 
     [self setViewpointCenter:_player.position];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
        // old contents of ccTouchEnded:withEvent:
        
//        CGPoint touchLocation = [touch locationInView: [touch view]]; 
//        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//        touchLocation = [self convertToNodeSpace:touchLocation];
//        
//        CGPoint playerPos = _player.position;
//        CGPoint diff = ccpSub(touchLocation, playerPos);
//        if (abs(diff.x) > abs(diff.y)) {
//            if (diff.x >0) {
//                playerPos.x += _tileMap.tileSize.width;
//                [self.player runAction:[CCRepeatForever actionWithAction: seqRight ]];
//
//            } else {
//                playerPos.x -= _tileMap.tileSize.width; 
//            } 
//        } else {
//            if (diff.y >0) {
//                playerPos.y += _tileMap.tileSize.height;
//            } else {
//                playerPos.y -= _tileMap.tileSize.height;
//            }
//        }
//        
//        if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
//            playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
//            playerPos.y >=0&&
//            playerPos.x >=0 ) 
//        {
//            [[SimpleAudioEngine sharedEngine] playEffect:@"move.caf"];
//            [self setPlayerPosition:playerPos];
//        }
//        
//        [self setViewpointCenter:_player.position];
    
//    NSLog(@"ccTouchEnded");
//    CGPoint touchLocation = [touch locationInView: [touch view]];		
//    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//    touchLocation = [self convertToNodeSpace:touchLocation];
//    
//    CGPoint moveVector = ccpSub(touchLocation, _player.position);
//    
//	float distanceToMove = ccpLength(moveVector);
//    CGFloat moveAngle = ccpToAngle(moveVector);
//    CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * moveAngle);
//    
//	float dragonVelocity = 480.0/3.0;
//	float moveDuration = distanceToMove / dragonVelocity;
//	
//	cocosAngle += 46;
//	if (cocosAngle < 0)
//		cocosAngle += 360;
//	
//	int runAnim = (int)((cocosAngle)/90);
//    NSLog(@"run angle11 %d", runAnim);
//    if (runAnim == 0) {
//        runAnim = 3;
//    }
//    else if (runAnim == 3) {
//        runAnim = 0;
//    }
//    
//    NSLog(@"run angle22 %d", runAnim);
//	[_player stopAction:_moveAction];
//	self.moveAction = [_actionArray objectAtIndex:runAnim];
//	[_player runAction:_moveAction];
//	
//	
//    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(callDelegate)];
//    self.walkAction = [CCSequence actions:
//                       [CCMoveTo actionWithDuration:moveDuration position:touchLocation],actionMoveDone,
//                       nil
//                       ];
//
//    [_player runAction:_walkAction]; 
//    [self setViewpointCenter:touchLocation];

    
}

-(void) callDelegate
{
//    [_player stopAction:_moveAction];
    
}

-(void) refreshBackground
{
    
//    [self setViewpointCenter:_player.position];
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
    self.actionArray = nil;
    self.moveAction = nil;
    self.walkAction = nil;
    self.joyStick = nil;
}

-(void) update:(ccTime)deltaTime
{
    [self setViewpointCenter:_player.position];

}

@end
