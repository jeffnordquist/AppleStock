//
//  StockPricesViewController.m
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import "StockPricesViewController.h"
#import "StockPricesModel.h"
#import "StockPrice.h"

NSString *dataSource = @"stockprices.json";

@interface StockPricesViewController ()

@end

@implementation StockPricesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
	[super viewDidAppear];

	[[StockPricesModel sharedInstance] loadDataFromSource:dataSource];
	[self drawGrid];
}
- (void)drawGrid {
//	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithWindow:[[self view] window]];
	NSRect windowRect = [[self view] window].frame;
	NSBezierPath *axes = [NSBezierPath bezierPath];
	[axes moveToPoint:NSMakePoint(40, windowRect.size.height - 30)];
	[axes lineToPoint:NSMakePoint(40, 30)];
	[axes lineToPoint:NSMakePoint(windowRect.size.width - 30, 30)];
	[axes setLineWidth:2.0];
	[axes stroke];
	
	StockPricesModel *model = [StockPricesModel sharedInstance];
	
	// Dates
	const NSUInteger numDates = model.pricesArray.count;
	float dateSpacing = (windowRect.size.width - 60) / numDates;
	float dateXPos = 60;
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"M/d"];
	for (NSUInteger dateNum = 0; dateNum < numDates; dateNum++) {
		NSString *dateString = [dateFormatter stringFromDate:((StockPrice *)model.pricesArray[dateNum]).date];
		[dateString drawAtPoint:NSMakePoint(dateXPos, 10) withAttributes:nil];
		dateXPos += dateSpacing;
	}
	
	// Prices
	NSUInteger numPrices = model.pricesArray.count;
	NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setMaximumFractionDigits:0];
	[priceFormatter setCurrencyCode:@"USD"];
	
	NSNumber *highestPrice = [model highestPrice];
	NSNumber *lowestPrice = [model lowestPrice];
	NSInteger numPriceTicks = [highestPrice integerValue] - [lowestPrice integerValue] + 2;
	float priceSpacing = (windowRect.size.height - 60) / numPriceTicks;
	float priceYPos = 40;
	for (NSInteger currPrice = [lowestPrice integerValue] - 1; currPrice < [highestPrice integerValue] + 1; currPrice++) {
		NSString *priceString = [priceFormatter stringFromNumber:[NSNumber numberWithInteger:currPrice]];
		[priceString drawAtPoint:NSMakePoint(5, priceYPos) withAttributes:nil];
		priceYPos += priceSpacing;
	}
}

@end



















