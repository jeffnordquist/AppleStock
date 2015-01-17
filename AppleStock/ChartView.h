//
//  StockPricesView.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSString	*dataSource = @"stockprices.json";
NSUInteger	chartDataPointCircleRadius = 5;
NSUInteger	chartVerticalAxisInset = 40;
NSUInteger	chartTopMargin = 20;
NSUInteger	chartBottomMargin = 30;
NSUInteger	chartRightMargin = 30;
float		chartLineWidth = 2.0;
NSUInteger	chartDateLabelInset = 60;
NSUInteger	chartPriceLabelTopInset = 30;
NSUInteger	chartPriceLabelBottomInset = 40;

@interface ChartView : NSView <NSWindowDelegate>

@property (strong,nonatomic) NSMutableDictionary *dateXCoordinates;
@property (strong,nonatomic) NSMutableDictionary *priceYCoordinates;
@property (strong,nonatomic) NSMutableArray *dataPointCoordinates;

@end
