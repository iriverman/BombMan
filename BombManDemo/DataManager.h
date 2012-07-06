//
//  DataManager.h
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

@interface DataManager : NSObject
{
	int currentlevel;
	int score;
	
	NSArray *levels;
	NSUserDefaults *defaults;
}

@property (readwrite) int currentlevel;
@property (readwrite) int score;

@property (nonatomic, retain) NSArray *levels;
@property (nonatomic, retain) NSUserDefaults *defaults;

- (BOOL) connectedToNetwork;

+ (DataManager *) sharedManager;

@end
