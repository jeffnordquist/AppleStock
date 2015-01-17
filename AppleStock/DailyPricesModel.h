//
//  StockPricesModel.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyPricesModel : NSObject

@property (strong,nonatomic) NSMutableArray *pricesArray;

+ (instancetype)sharedInstance;

- (void)loadDataFromSource:(NSString *)fileName;
- (NSNumber *)highestPrice;
- (NSNumber *)lowestPrice;

@end

