//
//  DailyPricesModel.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//
//	Purpose: Loads and maintains the daily stock prices.
//

#import <Foundation/Foundation.h>

@interface DailyPricesModel : NSObject

@property (strong,nonatomic) NSMutableArray *dailyPrices;

+ (instancetype)sharedInstance;

- (void)loadDataFromSource:(NSString *)fileName;
- (NSNumber *)highestPrice;
- (NSNumber *)lowestPrice;

@end

