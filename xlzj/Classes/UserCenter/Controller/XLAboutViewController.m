
//
//  XLAboutViewController.m
//  xlzj
//
//  Created by 周绪刚 on 16/5/25.
//  Copyright © 2016年 周绪刚. All rights reserved.
//

#import "XLAboutViewController.h"

@implementation XLAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于";
    self.view.backgroundColor = kBackgroundColor;
    
    [self initNaviBar];
    
    [self initContainer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self NaviBarShow:YES];
}

- (void)initNaviBar
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"back"];
    backBtn.frame = CGRectMake(0, 0, image.size.width/2 * 1.2, image.size.height/2 * 1.2);
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setBackgroundImage:image forState:UIControlStateSelected];
    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initContainer
{
    UIImageView *logoView = [[UIImageView alloc]init];
    logoView.image = [UIImage imageNamed:@"logo"];
    logoView.layer.masksToBounds = YES;
    logoView.layer.cornerRadius = 10;
    [self.view addSubview:logoView];
    [logoView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [logoView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:60.0];
    [logoView autoSetDimensionsToSize:CGSizeMake(80.0, 80.0)];
    
    UILabel *versionLabel = [[UILabel alloc]init];
    [versionLabel setText:@"e管家 V1.6.0"];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    versionLabel.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:versionLabel];
    [versionLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [versionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:logoView withOffset:10.0];
    [versionLabel autoSetDimensionsToSize:CGSizeMake(120.0, 30.0)];
    
    UILabel *descLabel1 = [[UILabel alloc]init];
    [descLabel1 setText:@"        EK 是意大利著名的制冷与空调设备制造企业--EUROKLIMAT集团旗下居家品牌，致力于民用住宅的空气品质和舒适度，以匠心，筑清新。"];
    [descLabel1 setTextAlignment:NSTextAlignmentJustified];
    descLabel1.font = [UIFont systemFontOfSize:19.0];
    descLabel1.numberOfLines = 0;
    [self.view addSubview:descLabel1];
    [descLabel1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [descLabel1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:versionLabel withOffset:30.0];
    [descLabel1 autoSetDimensionsToSize:CGSizeMake(kMainScreenSizeWidth - 30.0, 150.0)];
    
    // 调整行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:descLabel1.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [descLabel1.text length])];
    descLabel1.attributedText = attributedString;
    [descLabel1 sizeToFit];
    
    //
    UILabel *descLabel2 = [[UILabel alloc]init];
    [descLabel2 setText:@"        更多信息,请访问EK智能居家中央空调官方网址www.ek-home.top"];
    [descLabel2 setTextAlignment:NSTextAlignmentJustified];
    descLabel2.font = [UIFont systemFontOfSize:19.0];
    descLabel2.numberOfLines = 0;
    [self.view addSubview:descLabel2];
    [descLabel2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [descLabel2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:descLabel1 withOffset:30.0];
    [descLabel2 autoSetDimensionsToSize:CGSizeMake(kMainScreenSizeWidth - 30.0, 60.0)];
}

@end
