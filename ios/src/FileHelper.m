//
//  FileHelper.m
//  RNFileShareIntent
//
//  Created by Valentyn Halkin on 8/19/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "FileHelper.h"
#import <UIKit/UIKit.h>


@implementation FileHelper

+ (NSString *)MIMETypeFromPath:(NSString *)filePath
{
    NSString *extension = [filePath pathExtension];
    NSString *exportedUTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)exportedUTI, kUTTagClassMIMEType);

    return mimeType;
}
+ (NSString *)fileNameFromPath:(NSString *)filePath
{
    return [filePath lastPathComponent];
}

+ (NSDictionary *)getFileData:(NSURL *)url
{
    NSString *newUrl = [FileHelper saveImageToAppGroupFolder:url];
    
    NSError* error;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:newUrl error:&error];

    NSDictionary *fileData = @{
                               @"mime": [FileHelper MIMETypeFromPath:newUrl],
                               @"name": [FileHelper fileNameFromPath: [url absoluteString]],
                               @"path": newUrl,
                               @"size": [NSNumber numberWithLongLong:[fileAttributes fileSize]]
                               };
    
    return fileData;
}

+ (UIImage *)fixRotation:(UIImage *)image{

    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ ( NSString * ) saveImageToAppGroupFolder: ( NSURL * ) image
{
    NSString *fileName = [[FileHelper fileNameFromPath: [image absoluteString]] stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];

    NSString *filePath = [[FileHelper getSharedFolderPath] stringByAppendingPathComponent: fileName ];
    NSError *error = nil;
    NSString *fileExt = [[[image absoluteString] pathExtension] lowercaseString];
    if ([fileExt isEqual: @"heic"]) {
        NSString *jpgPathToFile = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension: @"jpg"];

        UIImage *uiImageOriginal = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
        
        UIImage *uiImageRotated = [FileHelper fixRotation:uiImageOriginal];
        
        if(![UIImageJPEGRepresentation(uiImageRotated, 0.8) writeToFile:jpgPathToFile atomically:YES]) {
            NSLog(@"Could not convert HEIC at path %@ to path %@. er ror %@", image.path , jpgPathToFile, error);
        } else {
            NSLog(@"COVERTED SUCCESSFULLY");
        }
        
        filePath = jpgPathToFile;
    } else {
        UIImage *uiImageOriginal = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
        UIImage *uiImageRotated = [FileHelper fixRotation:uiImageOriginal];
        if(![UIImageJPEGRepresentation(uiImageRotated, 0.8) writeToFile:filePath atomically:YES]) {
            NSLog(@"Could not copy report at path %@ to path %@. error %@", image.path , filePath, error);
        } else {
            NSLog(@"COPIED SUCCESSFULLY");
        }
    }
    
    return filePath;
}

+ ( NSString * ) getSharedFolderPath
{
    NSString *APP_SHARE_GROUP = @"group.com.levuro.engage";
    NSURL *containerURL = [ [ NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier: APP_SHARE_GROUP ];
    NSString *documentsPath = containerURL.path;
    
    return documentsPath;
}

+ (void) clearSharedFolder
{
    NSString *path = [FileHelper getSharedFolderPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];
    NSError* err = nil;
    BOOL res = false;

    NSString* file;
    while (file = [en nextObject]) {
        res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }
}

@end
