//
//  StockPricesView.m
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import "ChartView.h"
#import "DailyPricesModel.h"
#import "DailyPrice.h"
#import <Quartz/Quartz.h>

@implementation ChartView

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		_dateXCoordinates = [NSMutableDictionary new];
		_priceYCoordinates = [NSMutableDictionary new];
		_dataPointCoordinates = [NSMutableArray new];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	[self.window setDelegate:self];

	[[DailyPricesModel sharedInstance] loadDataFromSource:dataSource];
	[self initPositionArrays];
	[self drawAxes];
	[self drawChartData:![self inLiveResize]];
}

- (void)initPositionArrays {
	[self initDateLabelPositions];
	[self initPriceLabelPositions];
	[self initDataPointCoordinates];
}

- (void)drawAxes {
	[self drawGrid];
	[self drawDates];
	[self drawPrices];
}

- (void)drawGrid {
	NSBezierPath *axes = [NSBezierPath bezierPath];
	[axes moveToPoint:NSMakePoint(chartVerticalAxisInset, self.frame.size.height - chartTopMargin)];
	[axes lineToPoint:NSMakePoint(chartVerticalAxisInset, chartBottomMargin)];
	[axes lineToPoint:NSMakePoint(self.frame.size.width - chartRightMargin, chartBottomMargin)];
	[axes setLineWidth:chartLineWidth];
	[axes stroke];
}

- (void)initDateLabelPositions {
	[_dateXCoordinates removeAllObjects];
	NSArray *pricesArray = [DailyPricesModel sharedInstance].pricesArray;
	const NSUInteger numDates = pricesArray.count;
	float dateSpacing = (self.frame.size.width - chartDateLabelInset) / numDates;
	float dateXPos = chartDateLabelInset;
	
	for (DailyPrice *currPrice in pricesArray) {
		_dateXCoordinates[currPrice.date] = [NSNumber numberWithInteger:dateXPos];
		dateXPos += dateSpacing;
	}
}

- (void)drawDates {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"M/d"];
	
	NSArray *pricesArray = [DailyPricesModel sharedInstance].pricesArray;
	for (DailyPrice *currPrice in pricesArray) {
		NSString *dateString = [dateFormatter stringFromDate:currPrice.date];
		float xPos = [_dateXCoordinates[currPrice.date] floatValue];
		[dateString drawAtPoint:NSMakePoint(xPos, chartDataPointCircleRadius * 2) withAttributes:nil];
	}
}

- (void)initPriceLabelPositions {
	[_priceYCoordinates removeAllObjects];
	NSInteger highestPrice = [[[DailyPricesModel sharedInstance] highestPrice] integerValue];
	NSInteger lowestPrice = [[[DailyPricesModel sharedInstance] lowestPrice] integerValue];
	NSInteger numPriceTicks = highestPrice - lowestPrice + 2;
	float priceSpacing = (self.frame.size.height - chartPriceLabelTopInset - chartPriceLabelBottomInset) / numPriceTicks;
	float priceYPos = chartPriceLabelBottomInset;
	
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
	
	NSInteger highestPrice = [[[DailyPricesModel sharedInstance] highestPrice] integerValue];
	NSInteger lowestPrice = [[[DailyPricesModel sharedInstance] lowestPrice] integerValue];
	for (NSInteger currPrice = lowestPrice - 1; currPrice <= highestPrice + 1; currPrice++) {
		NSString *priceString = [priceFormatter stringFromNumber:[NSNumber numberWithInteger:currPrice]];
		float yPos = [_priceYCoordinates[[NSNumber numberWithInteger:currPrice]] floatValue];
		[priceString drawAtPoint:NSMakePoint(chartDataPointCircleRadius, yPos) withAttributes:nil];
	}
}

- (void)initDataPointCoordinates {
	[_dataPointCoordinates removeAllObjects];
	for (DailyPrice *currPrice in [DailyPricesModel sharedInstance].pricesArray) {
		float xCoord = [_dateXCoordinates[currPrice.date] floatValue] + chartDataPointCircleRadius;
		NSInteger roundedPrice = [currPrice.price integerValue];
		float yCoord = [_priceYCoordinates[[NSNumber numberWithInteger:roundedPrice]] floatValue];
		NSPoint point = NSMakePoint(xCoord, yCoord);
		[_dataPointCoordinates addObject:[NSValue valueWithPoint:point]];
	}
}

- (void)drawChartData:(BOOL)animate {
	CGMutablePathRef chartData = CGPathCreateMutable();
	bool pathStarted = NO;
	
	for (NSValue *value in _dataPointCoordinates) {
		NSPoint point;
		[value getValue:&point];
		
		if (!pathStarted) {
			CGPathMoveToPoint(chartData, NULL, point.x, point.y);
			pathStarted = YES;
		} else {
			CGPathAddLineToPoint(chartData, NULL, point.x, point.y);
		}
		NSRect rect = NSMakeRect(point.x - chartDataPointCircleRadius, point.y - chartDataPointCircleRadius, chartDataPointCircleRadius * 2, chartDataPointCircleRadius * 2);
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
		[path fill];
	}
	
	NSArray *subLayers = [self.layer sublayers];
	for (CAShapeLayer *layer in subLayers) {
		[layer removeFromSuperlayer];
	}

	if (animate) {
		[self drawAnimatedPath:chartData];
	} else {
		NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];
		CGContextRef cgContext = nsContext.CGContext;
		CGContextSetLineWidth(cgContext, chartLineWidth);
		CGContextAddPath(cgContext, chartData);
		CGContextStrokePath(cgContext);
	}
	CFRelease(chartData);
}

- (void)drawAnimatedPath:(CGMutablePathRef)path {
	CAShapeLayer *pathLayer = [CAShapeLayer layer];
	pathLayer.frame = self.frame;
	pathLayer.path = path;
	pathLayer.strokeColor = [[NSColor blackColor] CGColor];
	pathLayer.fillColor = nil;
	pathLayer.lineWidth = chartLineWidth;
	pathLayer.lineJoin = kCALineJoinBevel;
	
	[self.layer addSublayer:pathLayer];
	
	CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	pathAnimation.duration = 2.0;
	pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
	[pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

@end