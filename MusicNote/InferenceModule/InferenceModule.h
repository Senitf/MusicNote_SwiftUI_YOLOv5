//
//  InferenceModule.h
//  MusicNote
//
//  Created by 김민호 on 2021/10/01.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InferenceModule : NSObject

- (nullable instancetype)initWithFileAtPath:(NSString*)filePath
    NS_SWIFT_NAME(init(fileAtPath:))NS_DESIGNATED_INITIALIZER;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (nullable NSArray<NSNumber*>*)detectImage:(void*)imageBuffer NS_SWIFT_NAME(detect(image:));

@end

NS_ASSUME_NONNULL_END
