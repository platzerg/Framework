//
//  PWBiergartenClient.m
//  Framework
//
//  Created by platzerworld on 05.02.14.
//  Copyright (c) 2014 platzerworld. All rights reserved.
//

#import "PWBiergartenClient.h"
#import "PWBiergarten.h"

@interface PWBiergartenClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

static NSString *const BaseURLString = @"http://biergartenservice.appspot.com/platzerworld/biergarten/holebiergarten";

@implementation PWBiergartenClient


- (id)init {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Fetching: %@",url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    [subscriber sendNext:json];
                }
                else {
                    [subscriber sendError:jsonError];
                }
            }
            else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSURL *url = [NSURL URLWithString:BaseURLString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"biergartenListe"] rac_sequence];        
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[PWBiergarten class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
