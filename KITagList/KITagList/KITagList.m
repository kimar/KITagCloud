//
//  KIViewController.m
//  KITagList
//
//  Created by Marcus Kida on 11.10.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//
//  Thanks to Dominic Wroblewski for inspiring me ;-)
//

#import "KITagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 2.0f
#define LABEL_MARGIN_DEFAULT 5.0f
#define BOTTOM_MARGIN_DEFAULT 5.0f
#define FONT_SIZE_DEFAULT 13.0f
#define HORIZONTAL_PADDING_DEFAULT 7.0f
#define VERTICAL_PADDING_DEFAULT 1.5f

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface KITagList()

- (void)touchedTag:(id)sender;

@end

@implementation KITagList

@synthesize view, automaticResize;
@synthesize tagDelegate = _tagDelegate;

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setupNotifications];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.automaticResize = YES;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
        [self setupNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
        [self setupNotifications];
    }
    return self;
}

- (void) setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self setNeedsLayout];
}

- (void) setTags:(NSArray *)array
{
    tagArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    if (automaticResize) {
        [self displayTags];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self setNeedsLayout];
    }
}

- (void)setViewOnly:(BOOL)viewOnly
{
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self setNeedsLayout];
    }
}

- (void)touchedTag:(id)sender
{
    UITapGestureRecognizer *t = (UITapGestureRecognizer *)sender;
    KITagView *tagView = (KITagView *)t.view;
    if(tagView && self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(tagList:selectedTag:)])
        [self.tagDelegate tagList:self selectedTag:tagView.originalTag];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self displayTags];
}

- (void)displayTags
{
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[KITagView class]]) {

            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }
    
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;

    for (KITag *tag in tagArray) {

        KITagView *tagView = [[KITagView alloc] initWithTag:tag];
    
        [tagView updateWithString:tag.text
                             font:self.font
               constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                          padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth
         ];
        
        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            [tagView setFrame:newRect];
        }
        
        previousFrame = tagView.frame;
        gotPreviousFrame = YES;
        
        [tagView setBackgroundColor:tagView.originalTag.backgroundColor];
        
        // Davide Cenzi, added gesture recognizer to label
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTag:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [tagView setUserInteractionEnabled:YES];
        [tagView addGestureRecognizer:gesture];
        NSLog(@"Added Gesture Recognizer");
        
        [self addSubview:tagView];

    }
    
    sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    self.contentSize = sizeFit;
}

- (CGSize)fittedSize
{
    return sizeFit;
}

- (void)dealloc
{
    view = nil;
    tagArray = nil;
    lblBackgroundColor = nil;
}

@end

@implementation KITag

@end

@implementation KITagView

- (id) initWithTag:(KITag *)tag
{
    if((self = [super init]))
    {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_label setTextColor:tag.textColor];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];

        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:CORNER_RADIUS];
        
        [self setOriginalTag:tag];
    }
    
    return self;
}

- (void)updateWithString:(NSString*)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth
{
    NSAttributedString *attributedText = [[NSAttributedString alloc]  initWithString:text attributes:@{NSFontAttributeName:font}];
    
    CGRect textRect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    
    CGSize textSize = textRect.size;
    
    textSize.width = MAX(textSize.width, minimumWidth);
    textSize.height += padding.height*2;

    self.frame = CGRectMake(0, 0, textSize.width+padding.width*2, textSize.height);
    _label.frame = CGRectMake(padding.width, 0, MIN(textSize.width, self.frame.size.width), textSize.height);
    _label.font = font;
    _label.text = text;
    
}

- (void)setLabelText:(NSString*)text
{
    [_label setText:text];
}

- (void)dealloc
{
    _label = nil;
}

@end
