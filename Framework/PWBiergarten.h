//
//  PWBiergarten.h
//  Framework
//
//  Created by platzerworld on 05.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import <Mantle.h>

@interface PWBiergarten : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber * biergartenid;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * strasse;
@property (nonatomic, strong) NSString * plz;
@property (nonatomic, strong) NSString * ort;
@property (nonatomic, strong) NSString * telefon;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * desc;
@property (nonatomic, strong) NSNumber * favorit;

@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
 
@end
