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
#import <QuartzCore/QuartzCore.h>

NSString *dataSource = @"stockprices.json";

@interface StockPricesViewController ()

@property (strong,nonatomic) NSMutableDictionary *dateXCoordinates;
@property (strong,nonatomic) NSMutableDictionary *priceYCoordinates;
@property (strong,nonatomic) NSMutableArray *priceLineCoordinates;

@end

@implementation StockPricesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	_dateXCoordinates = [NSMutableDictionary new];
	_priceYCoordinates = [NSMutableDictionary new];
	_priceLineCoordinates = [NSMutableArray new];
}

- (void)viewDidAppear {
	[super viewDidAppear];

	[[StockPricesModel sharedInstance] loadDataFromSource:dataSource];
	[self drawAxes];
	[self drawChartData];
}

- (void)drawAxes {
	[self drawGrid];
	[self setupDatePositionsArray];
	[self drawDates];
	[self setupPricePositionsArray];
	[self drawPrices];
	[self calcDataPoints];
}

- (void)drawGrid {
	NSRect windowRect = [[self view] window].frame;
	NSBezierPath *axes = [NSBezierPath bezierPath];
	[axes moveToPoint:NSMakePoint(40, windowRect.size.height - 30)];
	[axes lineToPoint:NSMakePoint(40, 30)];
	[axes lineToPoint:NSMakePoint(windowRect.size.width - 30, 30)];
	[axes setLineWidth:2.0];
	[axes stroke];
}

- (void)setupDatePositionsArray {
	NSArray *pricesArray = [StockPricesModel sharedInstance].pricesArray;
	const NSUInteger numDates = pricesArray.count;
	float dateSpacing = (self.view.window.frame.size.width - 60) / numDates;
	float dateXPos = 60;

	for (StockPrice *currPrice in pricesArray) {
		_dateXCoordinates[currPrice.date] = [NSNumber numberWithInteger:dateXPos];
		dateXPos += dateSpacing;
	}
}

- (void)drawDates {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"M/d"];
	
	NSArray *pricesArray = [StockPricesModel sharedInstance].pricesArray;
	for (StockPrice *currPrice in pricesArray) {
		NSString *dateString = [dateFormatter stringFromDate:currPrice.date];
		float xPos = [_dateXCoordinates[currPrice.date] floatValue];
		[dateString drawAtPoint:NSMakePoint(xPos, 10) withAttributes:nil];
	}
}

- (void)setupPricePositionsArray {
	NSInteger highestPrice = [[[StockPricesModel sharedInstance] highestPrice] integerValue];
	NSInteger lowestPrice = [[[StockPricesModel sharedInstance] lowestPrice] integerValue];
	NSInteger numPriceTicks = highestPrice - lowestPrice + 2;
	float priceSpacing = (self.view.frame.size.height - 60) / numPriceTicks;
	float priceYPos = 40;
	
	for (NSInteger currPrice = lowestPrice - 1; currPrice <= highestPrice + 1; currPrice++) {
		_priceYCoordinates[[NSNumber numberWithInteger:currPrice]] = [NSNumber numberWithInteger:priceYPos];
		priceYPos += priceSpacing;
	}
}


- (void)drawPrices {
	NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setMaximumFractionDigits:0];
	[priceFormatter setCurrencyCode:@"USD"];
	
	NSInteger highestPrice = [[[StockPricesModel sharedInstance] highestPrice] integerValue];
	NSInteger lowestPrice = [[[StockPricesModel sharedInstance] lowestPrice] integerValue];
	for (NSInteger currPrice = lowestPrice - 1; currPrice <= highestPrice + 1; currPrice++) {
		NSString *priceString = [priceFormatter stringFromNumber:[NSNumber numberWithInteger:currPrice]];
		float yPos = [_priceYCoordinates[[NSNumber numberWithInteger:currPrice]] floatValue];
		[priceString drawAtPoint:NSMakePoint(5, yPos) withAttributes:nil];
	}
}

- (void)calcDataPoints {
	for (StockPrice *currPrice in [StockPricesModel sharedInstance].pricesArray) {
		float xCoord = [_dateXCoordinates[currPrice.date] floatValue] + 5;
		NSInteger roundedPrice = [currPrice.price integerValue];
		float yCoord = [_priceYCoordinates[[NSNumber numberWithInteger:roundedPrice]] floatValue];
		NSPoint point = NSMakePoint(xCoord, yCoord);
		[_priceLineCoordinates addObject:[NSValue valueWithPoint:point]];
	}
}

- (void)drawChartData {
	CGMutablePathRef chartData = CGPathCreateMutable();
	bool pathStarted = NO;
	
	for (NSValue *value in _priceLineCoordinates) {
		NSPoint point;
		[value getValue:&point];
		
		if (!pathStarted) {
			CGPathMoveToPoint(chartData, NULL, point.x, point.y);
			pathStarted = YES;
		} else {
			CGPathAddLineToPoint(chartData, NULL, point.x, point.y);
		}
		NSRect rect = NSMakeRect(point.x - 5, point.y - 5, 10, 10);
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
		[path fill];
	}
	
	[self drawAnimatedPath:chartData];
	CFRelease(chartData);
}

- (void)drawAnimatedPath:(CGMutablePathRef)path {
	CAShapeLayer *pathLayer = [CAShapeLayer layer];
	pathLayer.frame = self.view.bounds;
	pathLayer.path = path;
	pathLayer.strokeColor = [[NSColor blackColor] CGColor];
	pathLayer.fillColor = nil;
	pathLayer.lineWidth = 2.0f;
	pathLayer.lineJoin = kCALineJoinBevel;
	
	[_animationView.layer addSublayer:pathLayer];
	
	CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	pathAnimation.duration = 2.0;
	pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
	[pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

@end



















