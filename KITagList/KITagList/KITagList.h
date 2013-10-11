//
//  KIViewController.h
//  KITagList
//
//  Created by Marcus Kida on 11.10.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//
//  Thanks to Dominic Wroblewski for inspiring me ;-)
//

#import <UIKit/UIKit.h>

@class KITagList;

@interface KITag : NSObject

@property (strong) NSString *text;
@property (strong) UIColor *textColor;
@property (strong) UIColor *backgroundColor;

@end

@protocol KITagListDelegate <NSObject>

@required

- (void)tagList:(KITagList *)tagList selectedTag:(KITag *)tag;

@end

@interface KITagList : UIScrollView
{
    UIView *view;
    NSArray *tagArray;
    CGSize sizeFit;
    UIColor *lblBackgroundColor;
}

@property (nonatomic) BOOL viewOnly;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) IBOutlet id<KITagListDelegate> tagDelegate;
@property (nonatomic) BOOL automaticResize;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) CGFloat labelMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;
@property (nonatomic, assign) CGFloat minimumWidth;

- (void) setTags:(NSArray *)array;
- (CGSize)fittedSize;

@end

@interface KITagView : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) KITag *originalTag;

- (id) initWithTag:(KITag *)tag;
- (void)updateWithString:(NSString*)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth;
- (void)setLabelText:(NSString*)text;

@end
