//
//  ChartViewController.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//
//	Notes:	Right now all of the work is done in the View. That's because all of the coordinate
//			data is based on the size of the view's frame. If I were to continue refactoring, or
//			if the chart was interactive, I would move more of the functionality in here; I'm a
//			little uncomfortable having *everything* in the View.
//


#import <Cocoa/Cocoa.h>

@interface ChartViewController : NSViewController

@end
