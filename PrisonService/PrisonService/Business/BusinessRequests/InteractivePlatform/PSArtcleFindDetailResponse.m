//
//  PSArtcleFindDetailResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArtcleFindDetailResponse.h"

@implementation PSArtcleFindDetailResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"detailModel":@"data"}];
}

@end