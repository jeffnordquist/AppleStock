//
//  ChartView.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//
//	Purpose: Manage the drawing of the stock price chart.
//
//	Notes:	Right now this View does all of the work. With more time - or if the chart
//			was interactive - I would probably move some of this to the ViewController.
//

#import <Cocoa/Cocoa.h>

NSString	*dataSource = @"stockprices.json";
NSUInteger	chartDataPointCircleRadius = 5;
NSUInteger	chartVerticalAxisInset = 40;
NSUInteger	chartTopMargin = 20;
NSUInteger	chartBottomMargin = 30;
NSUInteger	chartRightMargin = 30;
NSUInteger	chartDateLabelInset = 60;
NSUInteger	chartPriceLabelTopInset = 30;
NSUInteger	chartPriceLabelBottomInset = 40;
float		chartLineWidth = 2.0;
float		chartHorizontalGuideWidth = 0.5;

@interface ChartView : NSView <NSWindowDelegate>

@property (strong,nonatomic) NSMutableDictionary *dateXCoordinates;
@property (strong,nonatomic) NSMutableDictionary *priceYCoordinates;
@property (strong,nonatomic) NSMutableArray *dataPointCoordinates;

@end
