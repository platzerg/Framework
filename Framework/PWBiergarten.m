//
//  PWBiergarten.m
//  Framework
//
//  Created by platzerworld on 05.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWBiergarten.h"

@implementation PWBiergarten


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"biergartenid": @"id",
             @"name": @"name",
             @"strasse": @"strasse",
             @"plz": @"plz",
             @"ort": @"ort",
             @"telefon": @"telefon",
             @"url": @"url",
             @"email": @"email",
             @"desc": @"desc",
             @"favorit": @"favorit",
             @"icon": @"latitude",
             @"windBearing": @"longitude",
             };
 
}

#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)dateJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)favoritJSONTransformer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}



@end
