//
//  StockPricesItem.m
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import "DailyPrice.h"

@implementation DailyPrice

- (instancetype)init
{
	self = [super init];
	if (self) {
		_date = nil;
		_price = nil;
	}
	return self;
}

- (instancetype)initWithDate:(NSDate *)date price:(NSNumber *)price
{
	self = [super init];
	if (self) {
		_date = date;
		_price = price;
	}
	return self;
}
@end
