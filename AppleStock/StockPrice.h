//
//  StockPricesItem.h
//  AppleStock
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockPrice : NSObject

@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) NSNumber *price;

- (instancetype)initWithDate:(NSDate *)date price:(NSNumber *)price;

@end

