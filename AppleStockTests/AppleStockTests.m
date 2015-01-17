//
//  AppleStockTests.m
//  AppleStockTests
//
//  Created by Jeff Nordquist on 1/16/15.
//  Copyright (c) 2015 NQE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "DailyPricesModel.h"
#import "DailyPrice.h"

NSString *testDataSource = @"stockprices.json";

@interface AppleStockTests : XCTestCase

@end

@implementation AppleStockTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatModelIsInitialized {
	DailyPricesModel *stockPricesModel = [DailyPricesModel new];
	[stockPricesModel loadDataFromSource:testDataSource];
	XCTAssertEqual(stockPricesModel.pricesArray.count, 5);
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
	
	NSDate *testDate = [dateFormatter dateFromString:@"2014-09-09"];
	NSNumber *testPrice = [priceFormatter numberFromString:@"97.99"];
	NSNumber *resultPrice = [NSNumber new];
	
	for (DailyPrice *item in stockPricesModel.pricesArray) {
		if (item.date == testDate) {
			resultPrice = item.price;
			break;
		}
	}
	
	XCTAssert([resultPrice compare:testPrice] == NSOrderedSame);
}

- (void)testThatHighAndLowPricesAreCorrect {
	DailyPricesModel *stockPricesModel = [DailyPricesModel new];
	[stockPricesModel loadDataFromSource:testDataSource];

	NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
	NSNumber *highest = [priceFormatter numberFromString:@"102.66"];
	NSNumber *lowest = [priceFormatter numberFromString:@"93.00"];
	
	XCTAssert([highest compare:[stockPricesModel highestPrice]] == NSOrderedSame);
	XCTAssert([lowest compare:[stockPricesModel lowestPrice]] == NSOrderedSame);
}
@end






