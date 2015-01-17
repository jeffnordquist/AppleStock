//
//  StockPricesViewController.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChartViewController : NSViewController

@property (weak,nonatomic) IBOutlet NSView *chartView;
@property (weak,nonatomic) IBOutlet NSView *animationView;

@end
