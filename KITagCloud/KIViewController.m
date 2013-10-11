//
//  KIViewController.m
//  KITagList
//
//  Created by Marcus Kida on 11.10.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//

#import "KIViewController.h"
#import "KITagCloud.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface KIViewController () <KITagCloudDelegate>
{
    IBOutlet KITagCloud *_tagList;
}
@end

@implementation KIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *tagCloud = @"One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin. He lay on his armour-like back, and if he lifted his head a little he could see his brown belly, slightly domed and divided by arches into stiff sections. The bedding was hardly able to cover it and seemed ready to slide off any moment. His many legs, pitifully thin compared with the size of the rest of him, waved about helplessly as he looked. \"What's happened to me?\" he thought. It wasn't a dream. His room, a proper human room although a little too small, lay peacefully between its four familiar walls. A collection of textile samples lay spread out on the table - Samsa was a travelling salesman - and above it there hung a picture that he had recently cut out of an illustrated magazine and housed in a nice, gilded frame. It showed a lady fitted out with a fur hat and fur boa who sat upright, raising a heavy fur muff that covered the whole of her lower arm towards the viewer. Gregor then turned to look out the window at the dull weather. Drops";
    
    NSArray *tagTexts = [tagCloud componentsSeparatedByString:@" "];
    NSMutableArray *tags = [NSMutableArray new];
    for (NSString *tagText in tagTexts)
    {
        KITag *tag = [KITag new];
        tag.text = tagText;
        tag.backgroundColor = UIColorFromRGB(arc4random() % 16777216);
        tag.textColor = [UIColor whiteColor];
        [tags addObject:tag];
    }
    
    [_tagList setTags:tags];
    [self.view addSubview:_tagList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KITagListDelegate
- (void) tagCloud:(KITagCloud *)tagCloud selectedTag:(KITag *)tag
{
    [[[UIAlertView alloc] initWithTitle:@"Tag selected!"
                                message:[NSString stringWithFormat:@"\"%@\" has been selected!", tag.text]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}
@end
