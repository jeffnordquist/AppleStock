//
//  StockPricesModel.m
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import "StockPricesModel.h"
#import "StockPrice.h"

@implementation StockPricesModel

+ (instancetype)sharedInstance {
	static dispatch_once_t once;
	static id sharedInstance;
	dispatch_once(&once, ^{
		sharedInstance = [self new];
	});
	
	return sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_pricesArray = nil;
	}
	return self;
}

- (void)loadDataFromSource:(NSString *)fileName {
	
	NSString *dataSourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
	
	NSData *pricesData = [NSData dataWithContentsOfFile:dataSourcePath];
	if (pricesData) {
		NSError *error;
		NSDictionary *stockPrices = [NSJSONSerialization JSONObjectWithData:pricesData options:0 error:&error];
		if (error) {
			NSLog(@"%@", error);
		} else {
			_pricesArray = [NSMutableArray new];

			NSArray *pricesArray = stockPrices[@"stockdata"];
			if (pricesArray) {
				NSDateFormatter *dateFormatter = [NSDateFormatter new];
				[dateFormatter setDateFormat:@"yyyy-MM-dd"];
				NSNumberFormatter *priceFormatter = [NSNumberFormatter new];

				for (NSDictionary *item in pricesArray) {
					NSDate *date = [dateFormatter dateFromString:item[@"date"]];
					NSNumber *price = [priceFormatter numberFromString:item[@"close"]];
					StockPrice *newStockPriceItem = [[StockPrice alloc] initWithDate:date price:price];
					[_pricesArray addObject:newStockPriceItem];
				}
			}
		}
	}
}

- (NSNumber *)highestPrice {
	NSNumber *highest = nil;
	for (StockPrice *currentPrice in _pricesArray) {
		if (highest == nil ) {
			highest = currentPrice.price;
		} else {
			highest = ([currentPrice.price doubleValue] > [highest doubleValue] ? currentPrice.price : highest);
		}
	}
	return highest;
}

- (NSNumber *)lowestPrice {
	NSNumber *lowest = nil;
	for (StockPrice *currentPrice in _pricesArray) {
		if (lowest == nil ) {
			lowest = currentPrice.price;
		} else {
			lowest = ([currentPrice.price doubleValue] < [lowest doubleValue] ? currentPrice.price : lowest);
		}
	}
	return lowest;
}

@end



















