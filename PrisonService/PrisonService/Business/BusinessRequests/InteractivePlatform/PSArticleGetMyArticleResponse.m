//
//  PSArticleGetMyArticleResponse.m
//  PrisonService
//
//  Created by kky on 2019/9/17.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSArticleGetMyArticleResponse.h"

@implementation PSArticleGetMyArticleResponse
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"articles":@"data.articles"}];
}
@end
