//
//  ChartView.m
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
	[self drawChartFrame];
	[self drawChartData:![self inLiveResize]];
}


// MARK: Position array initializers

- (void)initPositionArrays {
	[self initDateLabelPositions];
	[self initPriceLabelPositions];
	[self initDataPointCoordinates];
}

// Calculate the position of each date label based on how many there are.
- (void)initDateLabelPositions {
	[_dateXCoordinates removeAllObjects];
	NSArray *pricesArray = [DailyPricesModel sharedInstance].dailyPrices;
	const NSUInteger numDates = pricesArray.count;
	float dateSpacing = (self.frame.size.width - chartDateLabelInset) / numDates;
	float dateXPos = chartDateLabelInset;
	
	for (DailyPrice *currPrice in pricesArray) {
		_dateXCoordinates[currPrice.date] = @(dateXPos);
		dateXPos += dateSpacing;
	}
}

// Calculate the position of each price label, based on the highest and lowest value.
// Add one at the top and one at the bottom to account for rounding.
- (void)initPriceLabelPositions {
	[_priceYCoordinates removeAllObjects];
	NSInteger highestPrice = [[[DailyPricesModel sharedInstance] highestPrice] integerValue];
	NSInteger lowestPrice = [[[DailyPricesModel sharedInstance] lowestPrice] integerValue];
	NSInteger numPriceTicks = highestPrice - lowestPrice + 2;
	float priceSpacing = (self.frame.size.height - chartPriceLabelTopInset - chartPriceLabelBottomInset) / numPriceTicks;
	float priceYPos = chartPriceLabelBottomInset;
	
	for (NSInteger currPrice = lowestPrice - 1; currPrice <= highestPrice + 1; currPrice++) {
		_priceYCoordinates[@(currPrice)] = @(priceYPos);
		priceYPos += priceSpacing;
	}
}

// Calculate the X and Y coordinates of each price point.
- (void)initDataPointCoordinates {
	[_dataPointCoordinates removeAllObjects];
	for (DailyPrice *currPrice in [DailyPricesModel sharedInstance].dailyPrices) {
		float xCoord = [_dateXCoordinates[currPrice.date] floatValue] + chartDataPointCircleRadius;
		NSInteger roundedPrice = [currPrice.price integerValue];
		float yCoord = [_priceYCoordinates[@(roundedPrice)] floatValue];
		NSPoint point = NSMakePoint(xCoord, yCoord);
		[_dataPointCoordinates addObject:[NSValue valueWithPoint:point]];
	}
}


// MARK: Drawing

- (void)drawChartFrame {
	[self initPositionArrays];
	[self drawAxes];
	[self drawDates];
	[self drawPrices];
}

- (void)drawAxes {
	// Draw the main X and Y axes.
	NSBezierPath *axes = [NSBezierPath bezierPath];
	[axes moveToPoint:NSMakePoint(chartVerticalAxisInset, self.frame.size.height - chartTopMargin)];
	[axes lineToPoint:NSMakePoint(chartVerticalAxisInset, chartBottomMargin)];
	[axes lineToPoint:NSMakePoint(self.frame.size.width - chartRightMargin, chartBottomMargin)];
	[axes setLineWidth:chartLineWidth];
	[axes stroke];
	
	// Draw the horizontal lines of the prices.
	[[NSColor lightGrayColor] set];
	
	for (NSNumber *entry in _priceYCoordinates) {
		float yPos = [_priceYCoordinates[entry] floatValue];
		NSRect lineBounds = NSMakeRect(chartVerticalAxisInset, yPos, self.frame.size.width - chartRightMargin, 1);
		NSBezierPath *line = [NSBezierPath bezierPathWithRect:lineBounds];
		[line setLineWidth:chartHorizontalGuideWidth];
		[line stroke];
	}
}

- (void)drawDates {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"M/d"];
	
	NSArray *pricesArray = [DailyPricesModel sharedInstance].dailyPrices;
	for (DailyPrice *currPrice in pricesArray) {
		NSString *dateString = [dateFormatter stringFromDate:currPrice.date];
		float xPos = [_dateXCoordinates[currPrice.date] floatValue];
		[dateString drawAtPoint:NSMakePoint(xPos, chartDataPointCircleRadius * 2) withAttributes:nil];
	}
}

- (void)drawPrices {
	DailyPricesModel *pricesModel = [DailyPricesModel sharedInstance];

	NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[priceFormatter setMaximumFractionDigits:0];
	[priceFormatter setCurrencyCode:@"USD"];
	
	NSInteger highestPrice = [[pricesModel highestPrice] integerValue];
	NSInteger lowestPrice = [[pricesModel lowestPrice] integerValue];

	// Draw every dollar between lowest and highest, plus a buffer to account for rounding.
	// If I were to extend this, I would check the top and bottom bounds and consider skipping
	// some values (only drawing every other value, or every 5th, etc.)
	for (NSInteger currPrice = lowestPrice - 1; currPrice <= highestPrice + 1; currPrice++) {
		NSString *priceString = [priceFormatter stringFromNumber:@(currPrice)];
		float yPos = [_priceYCoordinates[@(currPrice)] floatValue];
		[priceString drawAtPoint:NSMakePoint(chartDataPointCircleRadius, yPos) withAttributes:nil];
	}
}

- (void)drawChartData:(BOOL)animate {
	// Use a CGMutablePath so it can be animated.
	CGMutablePathRef chartData = CGPathCreateMutable();
	bool pathStarted = NO;
	
	for (NSValue *value in _dataPointCoordinates) {
		// Awkward NSValue-to-NSPoint conversion so I can use an NSArray. I could use a
		// homegrown array to avoid this.
		NSPoint point;
		[value getValue:&point];
		
		// Add this point to the line.
		if (!pathStarted) {
			CGPathMoveToPoint(chartData, NULL, point.x, point.y);
			pathStarted = YES;
		} else {
			CGPathAddLineToPoint(chartData, NULL, point.x, point.y);
		}
		
		// Add a dot for this point.
		NSRect rect = NSMakeRect(point.x - chartDataPointCircleRadius, point.y - chartDataPointCircleRadius, chartDataPointCircleRadius * 2, chartDataPointCircleRadius * 2);
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
		[path fill];
	}
	
	// Remove the sublayers, which cancels any animations and clears the line. We need this
	// for when the view is resized - especially if it's resized while animating.
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

// Animate the line draw using a CA layer.
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
	pathAnimation.fromValue = @(0.0);
	pathAnimation.toValue = @(1.0);
	[pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

@end