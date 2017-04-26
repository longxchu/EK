//
//  XLControlViewController.m
//  xlzj
//
//  Created by zhouxg on 16/5/23.
//  Copyright © 2016年 周绪刚. All rights reserved.
//

#import "XLControlViewController.h"
#import "XLEnergyViewController.h"
#import "XLRotaionView.h"
#import "XLRotaionViewAfter.h"
#import "XLDevice.h"
#import "XLPopoverView.h"
#import "Panel.h"

@interface XLControlViewController ()

@property (nonatomic ,strong) UIScrollView *scrollView;

@property (nonatomic ,strong) XLRotaionView *rotationView;
@property (nonatomic ,strong) XLRotaionViewAfter *rotationViewAfter;

@property (nonatomic ,strong) UIView *scrollCenterContainer;

/** 分享手机号弹出窗口 */
@property (nonatomic ,strong) UIView *shareView;
/** 分享填写的手机号 */
@property (nonatomic ,strong) UITextField *shareField;

@property (nonatomic, assign) BOOL isStatusForFive;
// 正在动画中
@property (nonatomic ,assign) BOOL isAnimating;
// 正在旋转
@property (nonatomic ,assign) BOOL rotateChange;

/** 定时器每秒调用一次getDeviceInfo */
@property (nonatomic ,strong) NSTimer *timer;

/** 当前设备 */
@property (nonatomic ,strong) XLDevice *device;
/** 转盘中间的大温度值 */
@property (nonatomic ,strong) UILabel *valTempLabel;
/** 转盘中间的相对湿度值 */
@property (nonatomic ,strong) UIButton *valRHButton;
/** 最上面显示的可调节温度值 */
@property (nonatomic ,strong) UILabel *valExprTempLabel;
/** 室内环境描述 */
@property (nonatomic ,strong) UILabel *eqDescLabel;
/** 指针 Start */
@property (nonatomic, strong)Panel *panelView1;
@property (nonatomic, strong)Panel *panelView2;
/** 指针 End */
@property (nonatomic ,strong) NSString *strEdition;
/** DMI返回数组 */
@property (nonatomic ,strong) NSArray *getDeviceInfoArr;

/** Segment_start */
@property (nonatomic ,strong) UIView *segmentContainer;

@property (nonatomic ,strong) UIButton *singleWorkModelButton;
@property (nonatomic ,strong) UIButton *singleFirst;
@property (nonatomic ,strong) UIButton *singleSecond;
@property (nonatomic ,strong) UIButton *singleThird;

@property (nonatomic ,strong) UIButton *allFirst;
@property (nonatomic ,strong) UIButton *allSecond;
@property (nonatomic ,strong) UIButton *allThird;
@property (nonatomic ,strong) UIButton *allFour;
@property (nonatomic ,strong) UIButton *allFive;
// 场景功能
@property (nonatomic ,strong) UIButton *allWorkModelButton;
@property (nonatomic ,strong) UIButton *ecoButton;
@property (nonatomic ,strong) UIButton *assistantHeat;
@property (nonatomic ,strong) UIButton *sleep;
@property (nonatomic ,assign) int workModelIndex;
// 模式功能
@property (nonatomic ,strong) UIButton *allRunModelButton;
@property (nonatomic ,strong) UIButton *hot;
@property (nonatomic ,strong) UIButton *cold;
@property (nonatomic ,strong) UIButton *dehumidifier;
@property (nonatomic ,strong) UIButton *draft;
@property (nonatomic ,strong) UIButton *automatic;
// 风速功能
@property (nonatomic ,strong) UIButton *allFanSpeedButton;
@property (nonatomic ,strong) UIButton *smallWind;
@property (nonatomic ,strong) UIButton *middleWind;
@property (nonatomic ,strong) UIButton *bigWind;
@property (nonatomic ,strong) UIButton *autoWind;
@property (nonatomic ,strong) UIButton *verticalWind;
@property (nonatomic ,strong) UIButton *horizontalWind;
@property (nonatomic ,assign) int fanSpeed;
@property (nonatomic ,assign) int fanDirection;
@property (nonatomic ,assign) int fanIndex;
// 状态功能
@property (nonatomic ,strong) UIButton *allStatusButton;
@property (nonatomic ,strong) UIButton *statusRightOrError;
@property (nonatomic ,strong) UIButton *statusMsgRightOrError;
@property (nonatomic ,strong) UIButton *statusMotorOnOrOff;
@property (nonatomic ,strong) UIButton *statusIceOnOrOff;


/** Segment_end */

/** 四个控制按钮 */
@property (nonatomic ,strong) UIButton *lockBtn;
@property (nonatomic ,strong) UIButton *powerBtn;
/** 四个控制按钮 */

/** ° */
@property (nonatomic ,strong) UILabel *duLabel;


@property (nonatomic, copy) NSString *temp;
@end

@implementation XLControlViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.title = self.titleLabel;
    
    UIImageView *bgView = [[UIImageView alloc]init];
    [bgView setImage:[UIImage imageNamed:@"device_control_bg"]];
    [self.view addSubview:bgView];
    [bgView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self initNaviBar];
    
    [self initTopView];
    
    [self initScrollCenterView];
    
    [self initShareView];
    
    self.rotationViewAfter.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self NaviBarShow:NO];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getDeviceInfoTimeFire) userInfo:nil repeats:YES];
    [self.timer fire];
    
    [self.valExprTempLabel setText:[NSString stringWithFormat:@"%.1f°",self.device.valExprTemp/2.0]];
    NSArray *strarray = [self.rotationView.temperatureLabel.text componentsSeparatedByString:@"°"];
    NSString *temp1 = strarray[0];
    self.rotationView.startScale = [temp1 floatValue];
    self.isStatusForFive = YES;
    [self initSegment];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(endTimer) name:@"UITouchPhaseBegan" object:nil];
    [center addObserver:self selector:@selector(endTimer) name:@"UITouchPhaseMoved" object:nil];
    [center addObserver:self selector:@selector(startTimer) name:@"UITouchPhaseEnded" object:nil];
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getDeviceInfoTimeFire) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)endTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)getDeviceInfoTimeFire
{
    // 1. 获取设备详细信息(此处不便于封装要用到string数据)
    NSDictionary *getDeviceInfo = @{@"strCmd":@"getDeviceInfo",@"strIndex":self.strIndex};
    NSString *getDeviceInfoDictJson = [XLDictionary dictionaryToJson:getDeviceInfo];
    NSString *getDeviceInfoCommand = [linkon_op dmiJsonCommand:getDeviceInfoDictJson];
//    NSLog(@"getDeviceInfoCommand : %@",getDeviceInfoCommand);
    
    // 2. 根据 retData 找到对应数组
    NSDictionary *getDeviceInfoDict = [XLDictionary dictionaryWithJsonString:getDeviceInfoCommand];
    self.getDeviceInfoArr = [getDeviceInfoDict valueForKey:@"retData"];
    self.device = [XLDevice mj_objectWithKeyValues:self.getDeviceInfoArr];
    self.strEdition = self.device.strEdition;
    
    // 3. 调整圆盘
    [self changeRotationView];
    
    // 1，是蓝色，0，是灰色
    if (self.device.stLock == 0)
    {
        self.lockBtn.selected = NO;
    }
    else if (self.device.stLock == 1)
    {
        self.lockBtn.selected = YES;
    }
    
    if (self.device.stPower == 0)
    {
        self.powerBtn.selected = YES;
        self.rotationView.userInteractionEnabled = NO;
    }
    else if (self.device.stPower == 1)
    {
        self.powerBtn.selected = NO;
        self.rotationView.userInteractionEnabled = YES;
    }
    
    // 定时更新场景模式下按钮的选中状态
    [self trackWorkModeSubButtonStatus];
    
    // 定时更新模式下按钮的选中状态
    [self trackRunModeSubButtonStatus];
    
    // 定时更新风速模式下按钮的选中状态
    [self trackFanSpeedSubButtonStatus];
    
    //定时更新第一模式和第二模式下的状态
    if([self.strEdition isEqualToString:@"CS-1A0"] || [self.strEdition isEqualToString:@"CS-1D0"] || [self.strEdition isEqualToString:@"CS-1D1"]|| [self.strEdition isEqualToString:@"CS-NULL"]|| [self.strEdition isEqualToString:@"CE-1A0"]|| [self.strEdition isEqualToString:@"CE-1D0"]|| [self.strEdition isEqualToString:@"CE-1D1"]|| [self.strEdition isEqualToString:@"CE-NULL"] || [self.strEdition isEqualToString:@"CS-1B0"] || [self.strEdition isEqualToString:@"CS-1C0"] || [self.strEdition isEqualToString:@"CS-1C1"] || [self.strEdition isEqualToString:@"CE-1C0"] || [self.strEdition isEqualToString:@"CE-1B0"]){
        
        [self StateUp];
    }
}
//定时更新第一模式和第二模式下的状态方法实现
-(void)StateUp {
    
    if (self.allWorkModelButton.selected)
    {
        if (self.device.valWorkMode == 0)
        {
            [self.allWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
        }
        else if (self.device.valWorkMode == 1)
        {
            [self.allWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
        }
        else if (self.device.valWorkMode == 2)
        {
            [self.allWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
        }
    }
    // single
    if (self.singleWorkModelButton.selected)
    {
        if (self.device.valWorkMode == 0)
        {
            [self.singleWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
            self.singleFirst.selected = YES;
            self.singleSecond.selected = NO;
            self.singleThird.selected = NO;
        }
        else if (self.device.valWorkMode == 1)
        {
            [self.singleWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
            self.singleFirst.selected = NO;
            self.singleSecond.selected = YES;
            self.singleThird.selected = NO;
        }
        else if (self.device.valWorkMode == 2)
        {
            [self.singleWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
            self.singleFirst.selected = NO;
            self.singleSecond.selected = NO;
            self.singleThird.selected = YES;
        }
    }
    
    if (self.allRunModelButton.selected)
    {
        if (self.device.valRunMode == 1)
        {
            [self.allRunModelButton setTitle:@"制冷" forState:UIControlStateNormal];
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
            self.allFour.selected = NO;
            self.allFive.selected = NO;
        }
        else if (self.device.valRunMode == 0)
        {
            [self.allRunModelButton setTitle:@"制热" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = YES;
            self.allFive.selected = YES;
            
        }
        else if (self.device.valRunMode == 2)
        {
            [self.allRunModelButton setTitle:@"换气" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
            self.allFour.selected = NO;
            self.allFive.selected = NO;
            
        }
        else if (self.device.valRunMode == 5)
        {
            [self.allRunModelButton setTitle:@"空调" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = YES;
            self.allFive.selected = NO;
            
        }
        else if (self.device.valRunMode == 4)
        {
            [self.allRunModelButton setTitle:@"暖气" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = NO;
            self.allFive.selected = YES;
            
        }
    }
    
    if (self.allFanSpeedButton.selected)
    {
        if (self.device.valFanSpeed == 0 || self.device.valFanSpeed % 16 == 0)
        {
            [self.allFanSpeedButton setTitle:@"低风" forState:UIControlStateNormal];
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
        }
        else if (self.device.valFanSpeed == 1 || self.device.valFanSpeed % 16 == 1)
        {
            [self.allFanSpeedButton setTitle:@"中风" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
        }
        else if (self.device.valFanSpeed == 2 || self.device.valFanSpeed % 16 == 2)
        {
            [self.allFanSpeedButton setTitle:@"高风" forState:UIControlStateNormal];
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
        }
    }
    
    if ([self.strEdition isEqualToString:@"CS-1A0"] || [self.strEdition isEqualToString:@"CS-1D0"] || [self.strEdition isEqualToString:@"CS-1D1"]|| [self.strEdition isEqualToString:@"CS-NULL"]|| [self.strEdition isEqualToString:@"CE-1A0"]|| [self.strEdition isEqualToString:@"CE-1D0"]|| [self.strEdition isEqualToString:@"CE-1D1"]|| [self.strEdition isEqualToString:@"CE-NULL"])
    {
        if (self.device.valWorkMode == 0)
        {
            [self.allWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
        }
        else if (self.device.valWorkMode == 1)
        {
            [self.allWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
        }
        else if (self.device.valWorkMode == 2)
        {
            [self.allWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
        }
    }
    else
    {
        if (self.device.valWorkMode == 0)
        {
            [self.allWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
        }
        else if (self.device.valWorkMode == 1)
        {
            [self.allWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
        }
        else if (self.device.valWorkMode == 2)
        {
            [self.allWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
        }
        
        if (self.device.valRunMode == 1)
        {
            [self.allRunModelButton setTitle:@"制冷" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 0)
        {
            [self.allRunModelButton setTitle:@"制热" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 2)
        {
            [self.allRunModelButton setTitle:@"换气" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 5)
        {
            [self.allRunModelButton setTitle:@"空调" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 4)
        {
            [self.allRunModelButton setTitle:@"暖气" forState:UIControlStateNormal];
        }
        
        
        if (self.device.valFanSpeed == 0 || self.device.valFanSpeed % 16 == 0)
        {
            [self.allFanSpeedButton setTitle:@"低风" forState:UIControlStateNormal];
        }
        else if (self.device.valFanSpeed == 1 || self.device.valFanSpeed % 16 == 1)
        {
            [self.allFanSpeedButton setTitle:@"中风" forState:UIControlStateNormal];
        }
        else if (self.device.valFanSpeed == 2 || self.device.valFanSpeed % 16 == 2)
        {
            [self.allFanSpeedButton setTitle:@"高风" forState:UIControlStateNormal];
        }
    }
}

- (void)changeRotationView
{
    /** 3. 调整 UI */
    // 根据当前温度来设置UI显示
    [self.valExprTempLabel setText:[NSString stringWithFormat:@"%.1f°",self.device.valExprTemp/2.0]];
    NSArray *strarray = [self.valExprTempLabel.text componentsSeparatedByString:@"°"];
    _temp = strarray[0];
    // 调整旋转转盘(注释此处代码.防止转动过程中,温度来回跳动)
    self.rotationView.startScale = [_temp floatValue];
    
    // 1. 中间转盘显示温度值
    NSString *valTempOriginStr = [NSString stringWithFormat:@"%.1f",self.device.valTemp/2.0];
    NSMutableAttributedString *valTempStr = [[NSMutableAttributedString alloc] initWithString:valTempOriginStr];
//    NSLog(@" ----------- %@",valTempOriginStr);
    if (![valTempOriginStr isEqualToString:@"0.0"])
    {
        [valTempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:40.0] range:NSMakeRange(0, 3)];
        [valTempStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30.0] range:NSMakeRange(3, 1)];
    }
    
    self.valTempLabel.attributedText = valTempStr;
    
    // 2. 中间转盘下面的湿度值
    NSString *percent = @"%";
    [self.valRHButton setTitle:[NSString stringWithFormat:@"%d%@",self.device.valRH,percent] forState:UIControlStateNormal];
    
    // 4. 室内环境评价
    if (self.device.eqDesc == 1)
    {
        [self.eqDescLabel setText:@"干冷"];
    }
    else if (self.device.eqDesc == 2)
    {
        [self.eqDescLabel setText:@"偏冷"];
    }
    else if (self.device.eqDesc == 3)
    {
        [self.eqDescLabel setText:@"湿冷"];
    }
    else if (self.device.eqDesc == 4)
    {
        [self.eqDescLabel setText:@"干燥"];
    }
    else if (self.device.eqDesc == 5)
    {
        [self.eqDescLabel setText:@"舒适"];
    }
    else if (self.device.eqDesc == 6)
    {
        [self.eqDescLabel setText:@"潮湿"];
    }
    else if (self.device.eqDesc == 7)
    {
        [self.eqDescLabel setText:@"干热"];
    }
    else if (self.device.eqDesc == 8)
    {
        [self.eqDescLabel setText:@"偏热"];
    }
    else if (self.device.eqDesc == 9)
    {
        [self.eqDescLabel setText:@"湿热"];
    }
    
    /** 设置旋转后转盘的指针 */
    //    NSLog(@"self.device.eqTemperature/120.0 : %f === self.device.eqHumidity/120.0 : %f",self.device.eqTemperature/120.0,self.device.eqHumidity/120.0);
    CGFloat angleUp = (self.device.eqTemperature/120.0 - 1) * M_PI * 2 / 3.0 + M_PI / 3.0;
    CGFloat angleDown = (self.device.eqHumidity/120.0 - 1) * M_PI * 2 / 3.0 + M_PI / 3.0 + M_PI;
    [self.panelView1 setIndicatorTransform:(angleUp)];
    [self.panelView2 setIndicatorTransform:(-angleDown)];
    /** 设置旋转后转盘的指针 */
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
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 20, 20);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareBtnClick:(UIButton *)button
{
    UIButton *showBtn = button;
    XLPopoverView *popoverView = [XLPopoverView new];
    
    if (self.device.linkType == 0)
    {
        popoverView.menuTitles = @[@"分享设备给朋友"];
    }
    
    [popoverView showFromView:showBtn selected:^(NSInteger index) {
        
        if (self.device.linkType == 0)
        {
            if (index == 0)
            {
                NSLog(@"分享设备给朋友");
                self.shareView.hidden = NO;
            }
        }
    }];
}

- (void)initShareView
{
    self.shareView = [[UIView alloc]init];
    self.shareView.layer.masksToBounds = YES;
    self.shareView.layer.cornerRadius = 5.0;
    self.shareView.backgroundColor = [UIColor whiteColor];
    self.shareView.hidden = YES;
    [self.view addSubview:self.shareView];
    [self.shareView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.shareView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.shareView autoSetDimensionsToSize:CGSizeMake(kMainScreenSizeWidth - 100.0, 137.0)];
    
    UILabel *shareLabel = [[UILabel alloc]init];
    [shareLabel setText:@"      分享"];
    [shareLabel setTextColor:kTextColor];
    [shareLabel setTextAlignment:NSTextAlignmentLeft];
    shareLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self.shareView addSubview:shareLabel];
    [shareLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [shareLabel autoSetDimension:ALDimensionHeight toSize:45.0];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self.shareView addSubview:line1];
    [line1 autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(45.0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [line1 autoSetDimension:ALDimensionHeight toSize:1.0];
    
    self.shareField = [[UITextField alloc]init];
    [self.shareField setPlaceholder:@"请输入分享对象的手机号"];
    [self.shareField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.shareField setBorderStyle:UITextBorderStyleNone];
    self.shareField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.shareView addSubview:self.shareField];
    [self.shareField autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(46.0, 10.0, 0, -5.0) excludingEdge:ALEdgeBottom];
    [self.shareField autoSetDimension:ALDimensionHeight toSize:45.0];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor lightGrayColor];
    [self.shareView addSubview:line2];
    [line2 autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(91.0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [line2 autoSetDimension:ALDimensionHeight toSize:1.0];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:kTextColor forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.shareView addSubview:confirmButton];
    [confirmButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(92.0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [confirmButton autoSetDimension:ALDimensionHeight toSize:45.0];
}

- (void)confirmButtonClick
{
    [SNAPI deviceShareWithDeviceID:self.device.devId mobile:self.shareField.text areaCode:@"86" success:^{
        [SVProgressHUD showSuccessWithStatus:@"分享设备成功!" maskType:SVProgressHUDMaskTypeBlack];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.domain maskType:SVProgressHUDMaskTypeBlack];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    self.shareView.hidden = YES;
}

- (void)initTopView
{
    UIView *container = [[UIView alloc]init];
    [self.view addSubview:container];
    [container autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(64.0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [container autoSetDimension:ALDimensionHeight toSize:kMainScreenSizeWidth];
    
    self.lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockBtn setImage:[UIImage imageNamed:@"device_lock_nomal"] forState:UIControlStateNormal];
    [self.lockBtn setImage:[UIImage imageNamed:@"device_lock_press"] forState:UIControlStateSelected];
    [self.lockBtn addTarget:self action:@selector(topViewBtnClick:) forControlEvents:UIControlEventTouchDown];
    self.lockBtn.tag = 1;
    [container addSubview:self.lockBtn];
    [self.lockBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:container withOffset:15.0];
    [self.lockBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:container withOffset:15.0];
    [self.lockBtn autoSetDimensionsToSize:CGSizeMake(54.0, 58.0)];
    self.powerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.powerBtn setImage:[UIImage imageNamed:@"device_power_off"] forState:UIControlStateSelected];
    [self.powerBtn setImage:[UIImage imageNamed:@"device_power_on"] forState:UIControlStateNormal];
    [self.powerBtn addTarget:self action:@selector(topViewBtnClick:) forControlEvents:UIControlEventTouchDown];
    self.powerBtn.tag = 2;
    [container addSubview:self.powerBtn];
    [self.powerBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:container withOffset:15.0];
    [self.powerBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:container withOffset:-15.0];
    [self.powerBtn autoSetDimensionsToSize:CGSizeMake(54.0, 58.0)];
    
    UIButton *windsetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [windsetBtn setImage:[UIImage imageNamed:@"device_windset_nomal"] forState:UIControlStateNormal];
    [windsetBtn setImage:[UIImage imageNamed:@"device_windset_press"] forState:UIControlStateSelected];
    [windsetBtn addTarget:self action:@selector(topViewBtnClick:) forControlEvents:UIControlEventTouchDown];
    windsetBtn.tag = 3;
    [container addSubview:windsetBtn];
    [windsetBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:container withOffset:15.0];
    [windsetBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:container withOffset:-15.0];
    [windsetBtn autoSetDimensionsToSize:CGSizeMake(54.0, 58.0)];
    
    UIButton *energyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [energyBtn setImage:[UIImage imageNamed:@"device_energy_nomal"] forState:UIControlStateNormal];
    [energyBtn setImage:[UIImage imageNamed:@"device_energy_press"] forState:UIControlStateSelected];
    [energyBtn addTarget:self action:@selector(energyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:energyBtn];
    [energyBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:container withOffset:-15.0];
    [energyBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:container withOffset:-15.0];
    [energyBtn autoSetDimensionsToSize:CGSizeMake(54.0, 58.0)];
    
    self.valExprTempLabel = [[UILabel alloc]init];
    self.valExprTempLabel.font = [UIFont systemFontOfSize:20.0];
    [self.valExprTempLabel setTextColor:[UIColor whiteColor]];
    [self.valExprTempLabel setTextAlignment:NSTextAlignmentCenter];
    [container addSubview:self.valExprTempLabel];
    [self.valExprTempLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.valExprTempLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:container];
    [self.valExprTempLabel autoSetDimensionsToSize:CGSizeMake(100, 45.0)];
    
    self.scrollView = [[UIScrollView alloc]init];
    [container addSubview:self.scrollView];
    [self.scrollView autoSetDimensionsToSize:CGSizeMake(250.0, 250.0)];
    [self.scrollView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.scrollView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    self.rotationViewAfter = [[XLRotaionViewAfter alloc]initWithFrame:CGRectMake(0, 0, 250.0, 250.0) superView:self.scrollView];
    [self.scrollView addSubview:self.rotationViewAfter];
    
    self.rotationView = [[XLRotaionView alloc]initWithFrame:CGRectMake(0, 0, 250.0, 250.0) superView:self.scrollView];
    self.rotationView.strIndex = self.strIndex;
    self.rotationView.temperatureLabel = self.valExprTempLabel;
    [self.scrollView addSubview:self.rotationView];
}

// 圆盘中间控件容器
- (void)initScrollCenterView
{
    self.scrollCenterContainer = [[UIView alloc]init];
    [self.scrollView addSubview:self.scrollCenterContainer];
    [self.scrollCenterContainer autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.scrollCenterContainer autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.scrollCenterContainer autoSetDimensionsToSize:CGSizeMake(80.0, 120.0)];
    
    UIImageView *pointView = [[UIImageView alloc]init];
    pointView.image = [UIImage imageNamed:@"indication"];
    [self.scrollCenterContainer addSubview:pointView];
    [pointView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.scrollCenterContainer];
    [pointView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [pointView autoSetDimensionsToSize:CGSizeMake(10.0, 10.0)];
    
    self.valTempLabel = [[UILabel alloc]init];
    [self.valTempLabel setTextAlignment:NSTextAlignmentCenter];
    [self.valTempLabel setTextColor:kTextColor];
    [self.scrollCenterContainer addSubview:self.valTempLabel];
    [self.valTempLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:pointView withOffset:25.0];
    [self.valTempLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.scrollCenterContainer withOffset:-2.0];
    [self.valTempLabel autoSetDimensionsToSize:CGSizeMake(80.0, 35.0)];
    
    self.duLabel = [[UILabel alloc]init];
    [self.duLabel setText:@"°"];
    [self.duLabel setTextColor:kTextColor];
    self.duLabel.font = [UIFont systemFontOfSize:30.0];
    [self.scrollCenterContainer addSubview:self.duLabel];
    [self.duLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:pointView withOffset:25.0];
    [self.duLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.valTempLabel];
    [self.duLabel autoSetDimensionsToSize:CGSizeMake(10.0, 35.0)];
    
    self.valRHButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.valRHButton setImage:[UIImage imageNamed:@"center_humidity"] forState:UIControlStateNormal];//16*26
    [self.valRHButton setTitleColor:kTextColor forState:UIControlStateNormal];
    self.valRHButton.userInteractionEnabled = NO;
    self.valRHButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 47);
    self.valRHButton.titleEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
    [self.scrollCenterContainer addSubview:self.valRHButton];
    [self.valRHButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.valRHButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.scrollCenterContainer withOffset:-20.0];
    [self.valRHButton autoSetDimensionsToSize:CGSizeMake(60.0, 13.0)];
    
    /** 指针 */
    self.panelView1 = [[Panel alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    self.panelView1.backgroundColor = [UIColor clearColor];
    [self.rotationViewAfter addSubview:self.panelView1];
    self.panelView1.hidden = YES;
    
    self.panelView2 = [[Panel alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    self.panelView2.backgroundColor = [UIColor clearColor];
    [self.rotationViewAfter addSubview:self.panelView2];
    self.panelView2.hidden = YES;
    /** 指针 */
    
    UIImageView *centerImageView = [[UIImageView alloc]initWithFrame:self.rotationViewAfter.frame];
    centerImageView.image = [UIImage imageNamed:@"top_center_dish"];
    [self.rotationViewAfter addSubview:centerImageView];
    
    self.eqDescLabel = [[UILabel alloc]init];
    [self.eqDescLabel setTextAlignment:NSTextAlignmentCenter];
    [self.eqDescLabel setFont:[UIFont boldSystemFontOfSize:35.0]];
    self.eqDescLabel.hidden = YES;
    [self.eqDescLabel setTextColor:kTextColor];
    [self.rotationViewAfter addSubview:self.eqDescLabel];
    [self.eqDescLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.eqDescLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.eqDescLabel autoSetDimensionsToSize:CGSizeMake(80.0, 33.0)];
}

- (void)topViewBtnClick:(UIButton *)button
{
    XLAppDelegate *appDelegate = (XLAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.canSoundPlay)
    {
        // 开始播放\继续播放
        [appDelegate.player play];
        [ECMusicTool stopMusic:appDelegate.songs[1]];
        [ECMusicTool playMusic:appDelegate.songs[1]];
    }
    
    if (appDelegate.canVibratePlay)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if (self.isAnimating)
    {
        return;
    }
    
    if (button.tag == 1)        // 锁
    {
        if (!button.selected)
        {
            button.selected = YES;
            
            [XLDMITools commandStrCmdWith:@"setLockStatus" withStrIndex:self.strIndex withValue:(NSString *)@(1)];
        }
        else
        {
            button.selected = NO;
            
            [XLDMITools commandStrCmdWith:@"setLockStatus" withStrIndex:self.strIndex withValue:(NSString *)@(0)];
        }
    }
    else if (button.tag == 2)   // 关闭
    {
        if (!button.selected)
        {
            button.selected = YES;
            
            [XLDMITools commandStrCmdWith:@"setPowerStatus" withStrIndex:self.strIndex withValue:@(0)];
        }
        else
        {
            button.selected = NO;
            
            [XLDMITools commandStrCmdWith:@"setPowerStatus" withStrIndex:self.strIndex withValue:@(1)];
        }
    }
    else if (button.tag == 3)   // wind
    {
        if (!button.selected)
        {
            button.selected = YES;
        }
        else
        {
            button.selected = NO;
        }
        
        button.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:1 animations:^{
            self.isAnimating = YES;
            if (!self.rotateChange)
            {
                self.rotateChange = YES;
                self.rotationView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
                self.scrollCenterContainer.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
                self.rotationViewAfter.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 0);
            }
            else
            {
                self.rotateChange = NO;
                self.rotationView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 0);
                self.scrollCenterContainer.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 0);
                self.rotationViewAfter.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.rotateChange)
                {
                    self.rotationView.hidden = YES;
                    self.scrollCenterContainer.hidden = YES;
                    self.rotationViewAfter.hidden = NO;
                    
                    //  中间文字 label
                    self.eqDescLabel.hidden = NO;
                    self.panelView1.hidden = NO;
                    self.panelView2.hidden = NO;
                }
                else
                {
                    self.rotationView.hidden = NO;
                    self.scrollCenterContainer.hidden = NO;
                    self.rotationViewAfter.hidden = YES;
                }
            });
        } completion:^(BOOL finished) {
            if (finished)
            {
                self.isAnimating = NO;
                button.userInteractionEnabled = YES;
            }
        }];
    }
}

- (void)energyBtnClick
{
    XLEnergyViewController *energy = [[XLEnergyViewController alloc]init];
    energy.strIndex = self.device.strIndex;
    [self presentViewController:energy animated:NO completion:nil];
}

- (void)initSegment
{
    UIView *segmentView = [[UIView alloc]initWithFrame:CGRectMake(10, kMainScreenSizeHeight - kMainScreenSizeWidth/2 - 55.0, kMainScreenSizeWidth - 20.0, 35.0)];
    [self.view addSubview:segmentView];
    
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"mode_control_bg"];
    [segmentView addSubview:bgImageView];
    [bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    CGFloat WIDTH = (kMainScreenSizeWidth - 30) / 4;
    //第一中模式
    if([self.strEdition isEqualToString:@"CS-1A0"] || [self.strEdition isEqualToString:@"CS-1D0"] || [self.strEdition isEqualToString:@"CS-1D1"]|| [self.strEdition isEqualToString:@"CS-NULL"]|| [self.strEdition isEqualToString:@"CE-1A0"]|| [self.strEdition isEqualToString:@"CE-1D0"]|| [self.strEdition isEqualToString:@"CE-1D1"]|| [self.strEdition isEqualToString:@"CE-NULL"]){
        bgImageView.image = [UIImage imageNamed:@"mode_control_bg1"];
        CGFloat WIDTH1 = (kMainScreenSizeWidth-30)/3;
        self.singleWorkModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.singleWorkModelButton setImage:[UIImage imageNamed:@"mode_temp_nomal"] forState:UIControlStateNormal];
        [self.singleWorkModelButton setImage:[UIImage imageNamed:@"mode_temp_press"] forState:UIControlStateSelected];
        [self.singleWorkModelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.singleWorkModelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.singleWorkModelButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.singleWorkModelButton.frame = CGRectMake(WIDTH1, 0, WIDTH1, 35.0);
        self.singleWorkModelButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH1-40.0);
        self.singleWorkModelButton.selected = YES;
        
        
        if (self.valWorkMode == 0)
        {
            [self.singleWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
            self.singleFirst.selected = YES;
        }
        else if (self.valWorkMode == 1)
        {
            [self.singleWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
            self.singleSecond.selected = YES;
        }
        else if (self.valWorkMode == 2)
        {
            [self.singleWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
            self.singleThird.selected = YES;
        }
        [segmentView addSubview:self.singleWorkModelButton];
        //调取相关方法
        [self initSingleSegmentContainer];
        //第二种模式 
    } else if([self.strEdition isEqualToString:@"CS-1B0"] || [self.strEdition isEqualToString:@"CS-1C0"] || [self.strEdition isEqualToString:@"CS-1C1"] || [self.strEdition isEqualToString:@"CE-1C0"] || [self.strEdition isEqualToString:@"CE-1B0"]){
        bgImageView.image = [UIImage imageNamed:@"mode_control_bg1"];
        CGFloat WIDTH1 = (kMainScreenSizeWidth-30)/3;
        //  底部segement 第一个按钮
        self.allWorkModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allWorkModelButton setImage:[UIImage imageNamed:@"mode_temp_nomal"] forState:UIControlStateNormal];
        [self.allWorkModelButton setImage:[UIImage imageNamed:@"mode_temp_press"] forState:UIControlStateSelected];
        [self.allWorkModelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allWorkModelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allWorkModelButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allWorkModelButton.frame = CGRectMake(0, 0, WIDTH1, 35.0);
        self.allWorkModelButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH1-40.0);
        self.allWorkModelButton.selected = YES;
        [self.allWorkModelButton addTarget:self action:@selector(allButtonSelected2:) forControlEvents:UIControlEventTouchDown];
        if (self.device.valWorkMode == 0)
        {
            [self.allWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
        }
        else if (self.device.valWorkMode == 1)
        {
            [self.allWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
        }
        else if (self.device.valWorkMode == 2)
        {
            [self.allWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
        }
        [segmentView addSubview:self.allWorkModelButton];
        
        // 第二个按钮
        self.allRunModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allRunModelButton setImage:[UIImage imageNamed:@"mode_cold_nomal"] forState:UIControlStateNormal];
        [self.allRunModelButton setImage:[UIImage imageNamed:@"mode_cold_press"] forState:UIControlStateSelected];
        [self.allRunModelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allRunModelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allRunModelButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allRunModelButton.frame = CGRectMake(WIDTH1, 0, WIDTH1, 35.0);
        self.allRunModelButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH1-40.0);
        [self.allRunModelButton addTarget:self action:@selector(allButtonSelected2:) forControlEvents:UIControlEventTouchDown];
        if (self.device.valRunMode == 1)
        {
            [self.allRunModelButton setTitle:@"制冷" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 0)
        {
            [self.allRunModelButton setTitle:@"制热" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 2)
        {
            [self.allRunModelButton setTitle:@"换气" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 5)
        {
            [self.allRunModelButton setTitle:@"空调" forState:UIControlStateNormal];
        }
        else if (self.device.valRunMode == 4)
        {
            [self.allRunModelButton setTitle:@"暖气" forState:UIControlStateNormal];
        }
        [segmentView addSubview:self.allRunModelButton];
        
        // 第三个按钮
        self.allFanSpeedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allFanSpeedButton setImage:[UIImage imageNamed:@"mode_wind_nomal"] forState:UIControlStateNormal];
        [self.allFanSpeedButton setImage:[UIImage imageNamed:@"mode_wind_press"] forState:UIControlStateSelected];
        [self.allFanSpeedButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allFanSpeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allFanSpeedButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allFanSpeedButton.frame = CGRectMake(WIDTH1*2, 0, WIDTH1, 35.0);
        self.allFanSpeedButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH1-40.0);
        [self.allFanSpeedButton addTarget:self action:@selector(allButtonSelected2:) forControlEvents:UIControlEventTouchDown];
        if (self.device.valFanSpeed == 0 || self.device.valFanSpeed % 16 == 0)
        {
            [self.allFanSpeedButton setTitle:@"低风" forState:UIControlStateNormal];
        }
        else if (self.device.valFanSpeed == 1 || self.device.valFanSpeed % 16 == 1)
        {
            [self.allFanSpeedButton setTitle:@"中风" forState:UIControlStateNormal];
        }
        else if (self.device.valFanSpeed == 2 || self.device.valFanSpeed % 16 == 2)
        {
            [self.allFanSpeedButton setTitle:@"高风" forState:UIControlStateNormal];
        }
        else {
            [self.allFanSpeedButton setTitle:@"低风" forState:UIControlStateNormal];
        }
        [segmentView addSubview:self.allFanSpeedButton];
         // 第四种模式
        if([self.strEdition isEqualToString:@"CE-1B0"] || [self.strEdition isEqualToString:@"CS-1B0"]){
            self.isStatusForFive = NO;
        }
        //调取相关方法
        [self initAllSegmentContainer];

    } else {
        //第三种模式
        // 场景
        self.allWorkModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allWorkModelButton setImage:[UIImage imageNamed:@"ctrl_scence_normal"] forState:UIControlStateNormal];
        [self.allWorkModelButton setImage:[UIImage imageNamed:@"ctrl_scence_press"] forState:UIControlStateSelected];
        [self.allWorkModelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allWorkModelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allWorkModelButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allWorkModelButton.frame = CGRectMake(0, 0, WIDTH, 35.0);
        self.allWorkModelButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH-40.0);
        self.allWorkModelButton.selected = YES;
        [self.allWorkModelButton addTarget:self action:@selector(allModelButtonSelected:) forControlEvents:UIControlEventTouchDown];
        [self.allWorkModelButton setTitle:@"场景" forState:UIControlStateNormal];
        [segmentView addSubview:self.allWorkModelButton];
        // 模式
        self.allRunModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allRunModelButton setImage:[UIImage imageNamed:@"ctrl_run_normal"] forState:UIControlStateNormal];
        [self.allRunModelButton setImage:[UIImage imageNamed:@"ctrl_run_press"] forState:UIControlStateSelected];
        [self.allRunModelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allRunModelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allRunModelButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allRunModelButton.frame = CGRectMake(WIDTH, 0, WIDTH, 35.0);
        self.allRunModelButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH-40.0);
        [self.allRunModelButton addTarget:self action:@selector(allModelButtonSelected:) forControlEvents:UIControlEventTouchDown];
        [self.allRunModelButton setTitle:@"模式" forState:UIControlStateNormal];
        [segmentView addSubview:self.allRunModelButton];
        // 风速
        self.allFanSpeedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allFanSpeedButton setImage:[UIImage imageNamed:@"mode_wind_nomal"] forState:UIControlStateNormal];
        [self.allFanSpeedButton setImage:[UIImage imageNamed:@"mode_wind_press"] forState:UIControlStateSelected];
        [self.allFanSpeedButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allFanSpeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allFanSpeedButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allFanSpeedButton.frame = CGRectMake(WIDTH*2, 0, WIDTH, 35.0);
        self.allFanSpeedButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH-40.0);
        [self.allFanSpeedButton addTarget:self action:@selector(allModelButtonSelected:) forControlEvents:UIControlEventTouchDown];
        [self.allFanSpeedButton setTitle:@"风速" forState:UIControlStateNormal];
        [segmentView addSubview:self.allFanSpeedButton];
        // 状态
        self.allStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.allStatusButton setImage:[UIImage imageNamed:@"ctrl_status_normal"] forState:UIControlStateNormal];
        [self.allStatusButton setImage:[UIImage imageNamed:@"ctrl_status_press"] forState:UIControlStateSelected];
        [self.allStatusButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.allStatusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        self.allStatusButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        self.allStatusButton.frame = CGRectMake(WIDTH*3, 0, WIDTH, 35.0);
        self.allStatusButton.imageEdgeInsets = UIEdgeInsetsMake(10.0, 24.0, 10.0, WIDTH-40.0);
        [self.allStatusButton addTarget:self action:@selector(allModelButtonSelected:) forControlEvents:UIControlEventTouchDown];
        [self.allStatusButton setTitle:@"状态" forState:UIControlStateNormal];
        [segmentView addSubview:self.allStatusButton];
        //调取相关方法
        [self initSegmentContainer];
    }
    
}
//第一种模式调取方法
- (void)initSingleSegmentContainer
{
    self.segmentContainer = [[UIView alloc] init];
    self.segmentContainer.frame = CGRectMake(10, kMainScreenSizeHeight - kMainScreenSizeWidth/2, kMainScreenSizeWidth - 20, (kMainScreenSizeWidth - 20)/2);
    [self.view addSubview:self.segmentContainer];
    
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"device_bottom_liner_bg"];
    bgImageView.layer.cornerRadius = 8.0;
    bgImageView.layer.masksToBounds = YES;
    [self.segmentContainer addSubview:bgImageView];
    [bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.singleFirst = [UIButton buttonWithType:UIButtonTypeCustom];
    self.singleFirst.frame = CGRectMake(40.0, (self.segmentContainer.height - 60)/2, 60.0, 60.0);
    [self.singleFirst setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.singleFirst setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    [self.singleFirst setTitle:@"恒温" forState:UIControlStateNormal];
    self.singleFirst.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.singleFirst addTarget:self action:@selector(singleButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.singleFirst];
    //    [self.singleFirst autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    //    [self.singleFirst autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40.0, 40.0, 40.0, 0) excludingEdge:ALEdgeRight];
    
    self.singleSecond = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.singleSecond setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.singleSecond setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    [self.singleSecond setTitle:@"节能" forState:UIControlStateNormal];
    self.singleSecond.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.singleSecond addTarget:self action:@selector(singleButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.singleSecond];
    [self.singleSecond autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    [self.singleSecond autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.singleSecond autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    self.singleThird = [UIButton buttonWithType:UIButtonTypeCustom];
    self.singleThird.frame = CGRectMake(CGRectGetMaxX(self.segmentContainer.frame) - 100.0, (self.segmentContainer.height - 60.0)/2, 60.0, 60.0);
    [self.singleThird setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.singleThird setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    [self.singleThird setTitle:@"离家" forState:UIControlStateNormal];
    self.singleThird.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.singleThird addTarget:self action:@selector(singleButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.singleThird];
    //    [self.singleThird autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    //    [self.singleThird autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40.0, 0, 40.0, 40.0) excludingEdge:ALEdgeLeft];
    //第一模式下的恒温 节能 离家.....
    if (self.valWorkMode == 0){
        
        self.singleFirst.selected = YES;
    }else if (self.valWorkMode == 1){
        
        self.singleSecond.selected = YES;
    }else if (self.valWorkMode == 2){
        
        self.singleThird.selected = YES;
    }
}
//第二种模式调取方法
- (void)initAllSegmentContainer
{
    self.segmentContainer = [[UIView alloc] init];
    // kMainScreenSizeHeight - 235.0 + 35
    self.segmentContainer.frame = CGRectMake(10, kMainScreenSizeHeight - kMainScreenSizeWidth/2, kMainScreenSizeWidth - 20, (kMainScreenSizeWidth - 20)/2);
    [self.view addSubview:self.segmentContainer];
    
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"device_bottom_liner_bg"];
    bgImageView.layer.cornerRadius = 8.0;
    bgImageView.layer.masksToBounds = YES;
    [self.segmentContainer addSubview:bgImageView];
    [bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.allFirst = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allFirst.frame= CGRectMake(30.0, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2, 60.0, 60.0);
    [self.allFirst setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.allFirst setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.allFirst.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.allFirst addTarget:self action:@selector(allSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.allFirst];
    //    [self.allFirst autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    //    [self.allFirst autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40.0, 40.0, 40.0, 0) excludingEdge:ALEdgeRight];
    //
    self.allSecond = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allSecond.frame= CGRectMake((kMainScreenSizeWidth - 20 - 60)/2, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2, 60.0, 60.0);
    [self.allSecond setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.allSecond setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.allSecond.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.allSecond addTarget:self action:@selector(allSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.allSecond];
    
    self.allThird = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allThird.frame = CGRectMake(kMainScreenSizeWidth - 10 - 100.0, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2, 60.0, 60.0);
    [self.allThird setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.allThird setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.allThird.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.allThird addTarget:self action:@selector(allSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.allThird];
    //    [self.allThird autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    //    [self.allThird autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40.0, 0, 40.0, 40.0) excludingEdge:ALEdgeLeft];
    //
    
    self.allFour = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allFour.hidden = YES;
    self.allFour.frame = CGRectMake(self.segmentContainer.width/3 - 30.0, CGRectGetMaxY(self.allFirst.frame) -22, 60.0, 60.0);
    [self.allFour setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.allFour setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.allFour.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.allFour addTarget:self action:@selector(allSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.allFour];
    //    [self.allFour autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    //    [self.allFour autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(40.0, 0, 40.0, 40.0) excludingEdge:ALEdgeTop];
    
    
    self.allFive = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allFive.hidden = YES;
    self.allFive.frame = CGRectMake(self.segmentContainer.width/3*2 - 30.0, CGRectGetMaxY(self.allFirst.frame) - 22 , 60.0, 60.0);
    [self.allFive setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.allFive setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.allFive.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.allFive addTarget:self action:@selector(allSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.allFive];
    
    if (self.device.valWorkMode == 0)
    {
        [self.allFirst setTitle:@"恒温" forState:UIControlStateNormal];
        [self.allSecond setTitle:@"节能" forState:UIControlStateNormal];
        [self.allThird setTitle:@"离家" forState:UIControlStateNormal];
        self.allFirst.selected = YES;
        self.allSecond.selected = NO;
        self.allThird.selected = NO;
    }
    else if (self.device.valWorkMode == 1)
    {
        [self.allFirst setTitle:@"恒温" forState:UIControlStateNormal];
        [self.allSecond setTitle:@"节能" forState:UIControlStateNormal];
        [self.allThird setTitle:@"离家" forState:UIControlStateNormal];
        self.allFirst.selected = NO;
        self.allSecond.selected = YES;
        self.allThird.selected = NO;
    }
    else if (self.device.valWorkMode == 2)
    {
        [self.allFirst setTitle:@"恒温" forState:UIControlStateNormal];
        [self.allSecond setTitle:@"节能" forState:UIControlStateNormal];
        [self.allThird setTitle:@"离家" forState:UIControlStateNormal];
        self.allFirst.selected = NO;
        self.allSecond.selected = NO;
        self.allThird.selected = YES;
    }
}
- (void)singleButtonSelected:(UIButton *)button
{
    XLAppDelegate *appDelegate = (XLAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.canSoundPlay)
    {
        // 开始播放\继续播放
        [appDelegate.player play];
        [ECMusicTool stopMusic:appDelegate.songs[1]];
        [ECMusicTool playMusic:appDelegate.songs[1]];
    }
    
    if (appDelegate.canVibratePlay)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if (self.device.stPower == 0)
    {
        return;
    }
    
    if (button == self.singleFirst)
    {
        self.singleFirst.selected = YES;
        self.singleSecond.selected = NO;
        self.singleThird.selected = NO;
        [self.singleWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
        
        // 发送恒温模式命令
        [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(0)];
    }
    else if (button == self.singleSecond)
    {
        self.singleFirst.selected = NO;
        self.singleSecond.selected = YES;
        self.singleThird.selected = NO;
        [self.singleWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
        
        // 发送节能模式命令
        [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(1)];
    }
    else if (button == self.singleThird)
    {
        self.singleFirst.selected = NO;
        self.singleSecond.selected = NO;
        self.singleThird.selected = YES;
        [self.singleWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
        
        // 发送离家模式命令
        [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(2)];
    }
}
- (void)allSubButtonSelected:(UIButton *)button
{
    XLAppDelegate *appDelegate = (XLAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.canSoundPlay)
    {
        // 开始播放\继续播放
        [appDelegate.player play];
        [ECMusicTool stopMusic:appDelegate.songs[1]];
        [ECMusicTool playMusic:appDelegate.songs[1]];
    }
    if (appDelegate.canVibratePlay)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if (self.device.stPower == 0)
    {
        return;
    }
    
    if (self.allWorkModelButton.selected)
    {
        if (button == self.allFirst)
        {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
            [self.allWorkModelButton setTitle:@"恒温" forState:UIControlStateNormal];
            // 发送恒温模式命令
            [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(0)];
        }
        else if (button == self.allSecond)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            [self.allWorkModelButton setTitle:@"节能" forState:UIControlStateNormal];
            // 发送节能模式命令
            [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(1)];
        }
        else if (button == self.allThird)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
            [self.allWorkModelButton setTitle:@"离家" forState:UIControlStateNormal];
            // 发送离家模式命令
            [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(2)];
        }
    }
    if (self.allRunModelButton.selected)
    {
        if (button == self.allFirst)
        {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
            self.allFour.selected = NO;
            self.allFive.selected = NO;
            [self.allRunModelButton setTitle:@"制冷" forState:UIControlStateNormal];
            // 发送制热冷式命令
            [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(1)];
        }
        else if (button == self.allSecond)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = YES;
            self.allFive.selected = YES;
            [self.allRunModelButton setTitle:@"制热" forState:UIControlStateNormal];
            // 发送制热模式命令（空调+暖气）
            [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(0)];
        }
        else if (button == self.allThird)
        {
            if(button.isSelected){
                return;
            }
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
            self.allFour.selected = NO;
            self.allFive.selected = NO;
            [self.allRunModelButton setTitle:@"换气" forState:UIControlStateNormal];
            // 发送换气模式命令
            [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(2)];
        }
        else if (button == self.allFour)
        {
            if(!self.allFive.isSelected && self.allFour.isSelected){
                return;
            }
            if(!button.isSelected){
                self.allSecond.selected = YES;
            }
            self.allFirst.selected = NO;
            self.allThird.selected = NO;
            self.allFour.selected = !self.allFour.selected;
            if(self.allFour.isSelected){
                // 发送 开启空暖的命令
                if(self.allFive.isSelected){
                    [self.allRunModelButton setTitle:@"制热" forState:UIControlStateNormal];
                    [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(0)];
                } else {
                    [self.allRunModelButton setTitle:@"空调" forState:UIControlStateNormal];
                    [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(5)];
                }
            } else {
                // 发送 关闭空暖的命令
                [self.allRunModelButton setTitle:@"暖气" forState:UIControlStateNormal];
                [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(4)];
            }
            // 发送空暖模式命令（暖气）
        }
        else if (button == self.allFive)
        {
            if(self.allFive.isSelected && !self.allFour.isSelected){
                return;
            }
            if(!button.isSelected){
                self.allSecond.selected = YES;
            }
            self.allFirst.selected = NO;
            self.allThird.selected = NO;
            self.allFive.selected = !self.allFive.selected;
            
            // 发送地暖模式命令
            if(self.allFive.isSelected){
                // 发送 开启地暖的命令
                if(self.allFour.isSelected){
                    [self.allRunModelButton setTitle:@"制热" forState:UIControlStateNormal];
                    [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(0)];
                } else {
                    [self.allRunModelButton setTitle:@"暖气" forState:UIControlStateNormal];
                    [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(4)];
                }
            } else {
                // 发送 关闭地暖的命令
                [self.allRunModelButton setTitle:@"空调" forState:UIControlStateNormal];
                [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(5)];
            }
        }
    }
    if (self.allFanSpeedButton.selected)
    {
        if (button == self.allFirst)
        {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
            [self.allFanSpeedButton setTitle:@"低风" forState:UIControlStateNormal];
            // 发送小风模式命令
            [XLDMITools commandStrCmdWith:@"setFanSpeed" withStrIndex:self.strIndex withValue:@(0)];
        }
        else if (button == self.allSecond)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            [self.allFanSpeedButton setTitle:@"中风" forState:UIControlStateNormal];
            // 发送中风模式命令
            [XLDMITools commandStrCmdWith:@"setFanSpeed" withStrIndex:self.strIndex withValue:@(1)];
        }
        else if (button == self.allThird)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
            [self.allFanSpeedButton setTitle:@"高风" forState:UIControlStateNormal];
            // 发送大风模式命令
            [XLDMITools commandStrCmdWith:@"setFanSpeed" withStrIndex:self.strIndex withValue:@(2)];
        }
    }
}
//第三种模式调取方法
- (void)initSegmentContainer
{
    self.segmentContainer = [[UIView alloc] init];
//    self.segmentContainer.backgroundColor = [UIColor yellowColor];
    self.segmentContainer.frame = CGRectMake(10, kMainScreenSizeHeight - kMainScreenSizeWidth/2, kMainScreenSizeWidth - 20, (kMainScreenSizeWidth - 20)/2);
    [self.view addSubview:self.segmentContainer];
    
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"device_bottom_liner_bg"];
    bgImageView.layer.cornerRadius = 8.0;
    bgImageView.layer.masksToBounds = YES;
    [self.segmentContainer addSubview:bgImageView];
    [bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self initWorkModelSegmentSubViews];
}

#pragma mark - 场景相关设置
#pragma mark -
- (void)initWorkModelSegmentSubViews
{
    self.ecoButton = [UIButton buttonWithType:UIButtonTypeCustom];//1
    self.ecoButton.frame = CGRectMake(40.0, (self.segmentContainer.height - 60.0)/2, 60.0, 60.0);
    [self.ecoButton setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.ecoButton setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.ecoButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.ecoButton setTitle:@"ECO" forState:UIControlStateNormal];
    [self.ecoButton addTarget:self action:@selector(allWorkModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.ecoButton];
    
    self.assistantHeat = [UIButton buttonWithType:UIButtonTypeCustom];//2
    [self.assistantHeat setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.assistantHeat setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.assistantHeat.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.assistantHeat setTitle:@"辅热" forState:UIControlStateNormal];
//*********只有模式下的制热开启 场景模式下的辅热才可点击
    if(self.device.valRunMode == 0){
        self.assistantHeat.enabled = YES;
    } else {
        self.assistantHeat.enabled = NO;
    }
    
    [self.assistantHeat addTarget:self action:@selector(allWorkModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.assistantHeat];
    [self.assistantHeat autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    [self.assistantHeat autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.assistantHeat autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    self.sleep = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.sleep.frame = CGRectMake(CGRectGetMaxX(self.segmentContainer.frame) - 100.0, (self.segmentContainer.height - 60.0)/2, 60.0, 60.0);
    [self.sleep setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.sleep setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.sleep.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.sleep setTitle:@"睡眠" forState:UIControlStateNormal];
    [self.sleep addTarget:self action:@selector(allWorkModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.sleep];
    
    [self trackWorkModeSubButtonStatus];
}

/**
 跟踪显示场景模式下按钮的选中状态
 */
-(void)trackWorkModeSubButtonStatus
{
    if (self.device.valWorkMode == 0)
    {
        self.ecoButton.selected = NO;
        self.assistantHeat.selected = NO;
        self.sleep.selected = NO;
    }
    else if (self.device.valWorkMode == 1)
    {
        self.ecoButton.selected = YES;
        self.assistantHeat.selected = NO;
        self.sleep.selected = NO;
    }
    else if (self.device.valWorkMode == 2)
    {
        self.ecoButton.selected = NO;
        self.assistantHeat.selected = YES;
        self.sleep.selected = NO;
    }
    else if (self.device.valWorkMode == 3)
    {
        self.ecoButton.selected = YES;
        self.assistantHeat.selected = YES;
        self.sleep.selected = NO;
    }
    else if (self.device.valWorkMode == 4)
    {
        self.ecoButton.selected = NO;
        self.assistantHeat.selected = NO;
        self.sleep.selected = YES;
    }
    else if (self.device.valWorkMode == 5)
    {
        self.ecoButton.selected = YES;
        self.assistantHeat.selected = NO;
        self.sleep.selected = YES;
    }
    else if (self.device.valWorkMode == 6)
    {
        self.ecoButton.selected = NO;
        self.assistantHeat.selected = YES;
        self.sleep.selected = YES;
    }
    else if (self.device.valWorkMode == 7)
    {
        self.ecoButton.selected = YES;
        self.assistantHeat.selected = YES;
        self.sleep.selected = YES;
    }
}
/**
 场景选择
 */
- (void)allModelButtonSelected:(UIButton *)button
{
    for (id obj in self.segmentContainer.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            [obj removeFromSuperview];
        }
    }
    
    if (button == self.allWorkModelButton)
    {
        [self initWorkModelSegmentSubViews];
        
        self.allWorkModelButton.selected = YES;
        self.allRunModelButton.selected = self.allFanSpeedButton.selected = self.allStatusButton.selected = NO;
        
        [self changeWorkModelStatusWithButton:button];
    }
    else if (button == self.allRunModelButton)
    {
        [self initRunModelSegmentSubViews];
        
        self.allRunModelButton.selected = YES;
        self.allWorkModelButton.selected = self.allFanSpeedButton.selected = self.allStatusButton.selected = NO;
        
        [self changeRunModelStatusWithButton:button];
    }
    else if (button == self.allFanSpeedButton)
    {
        [self initFanSpeedModelSegmentSubViews];
        
        self.allFanSpeedButton.selected = YES;
        self.allWorkModelButton.selected = self.allRunModelButton.selected = self.allStatusButton.selected = NO;
    }
    else if (button == self.allStatusButton)
    {
        [self initStatusModelSegmentSubViews];
        
        self.allStatusButton.selected = YES;
        self.allWorkModelButton.selected = self.allFanSpeedButton.selected = self.allRunModelButton.selected = NO;
    }
    
    [self canSoundOrVibratePlay];
}

- (void)changeWorkModelStatusWithButton:(UIButton *)button
{
    if (button == self.allWorkModelButton)
    {
        if (self.device.valWorkMode == 0)
        {
            self.ecoButton.selected = NO;
            self.assistantHeat.selected = NO;
            self.sleep.selected = NO;
        }
        else if (self.device.valWorkMode == 1)
        {
            self.ecoButton.selected = YES;
            self.assistantHeat.selected = NO;
            self.sleep.selected = NO;
        }
        else if (self.device.valWorkMode == 2)
        {
            self.ecoButton.selected = NO;
            self.assistantHeat.selected = YES;
            self.sleep.selected = NO;
        }
        else if (self.device.valWorkMode == 4)
        {
            self.ecoButton.selected = NO;
            self.assistantHeat.selected = NO;
            self.sleep.selected = YES;
        }
    }
}

- (void)allWorkModelSubButtonSelected:(UIButton *)button
{
    [self canSoundOrVibratePlay];
    
    if (self.device.stPower == 0)
    {
        return;
    }
    
    if (button == self.ecoButton)
    {
        self.ecoButton.selected = !self.ecoButton.selected;
        
        [self calculateWorkModeCmdValue];
        
        // 发送ECO命令
        [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(self.workModelIndex)];
    }
    else if (button == self.assistantHeat)
    {
        self.assistantHeat.selected = !self.assistantHeat.selected;
        
        [self calculateWorkModeCmdValue];
        
        // 发送辅热命令
        [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(self.workModelIndex)];
    }
    else if (button == self.sleep)
    {
        self.sleep.selected = !self.sleep.selected;
        
        [self calculateWorkModeCmdValue];
        
        // 发送睡眠命令
        [XLDMITools commandStrCmdWith:@"setWorkMode" withStrIndex:self.strIndex withValue:@(self.workModelIndex)];
    }
}

- (int)calculateWorkModeCmdValue
{
    int a;
    if (self.ecoButton.selected)
    {
        a = 1;
    }
    else
    {
        a = 0;
    }
    
    int b;
    if (self.assistantHeat.selected)
    {
        b = 2;
    }
    else
    {
        b = 0;
    }
    
    int c;
    if (self.sleep.selected)
    {
        c = 4;
    }
    else
    {
        c = 0;
    }
    
    self.workModelIndex = a + b + c;
    return self.workModelIndex;
}
#pragma mark - 场景相关设置
#pragma mark -

#pragma mark - 模式相关设置
#pragma mark -
- (void)initRunModelSegmentSubViews
{
    self.hot = [UIButton buttonWithType:UIButtonTypeCustom];//1
    self.hot.frame = CGRectMake(30.0, (self.segmentContainer.height - 60.0)/4 - 10.0, 60.0, 60.0);
    [self.hot setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.hot setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.hot.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.hot setTitle:@"制热" forState:UIControlStateNormal];
    [self.hot addTarget:self action:@selector(allRunModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.hot];
    
    self.cold = [UIButton buttonWithType:UIButtonTypeCustom];//2
    [self.cold setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.cold setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.cold.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.cold setTitle:@"制冷" forState:UIControlStateNormal];
    [self.cold addTarget:self action:@selector(allRunModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.cold];
    [self.cold autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    [self.cold autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.cold autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.segmentContainer withOffset:(self.segmentContainer.height - 60.0)/4 - 10.0];
    
    self.dehumidifier = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.dehumidifier.frame = CGRectMake(CGRectGetMaxX(self.segmentContainer.frame) - 100.0, (self.segmentContainer.height - 60.0)/4 - 10.0, 60.0, 60.0);
    [self.dehumidifier setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.dehumidifier setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.dehumidifier.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.dehumidifier setTitle:@"除湿" forState:UIControlStateNormal];
    [self.dehumidifier addTarget:self action:@selector(allRunModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.dehumidifier];
    
    self.draft = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.draft.frame = CGRectMake(self.segmentContainer.width/3 - 30.0, CGRectGetMaxY(self.hot.frame) + 20.0, 60.0, 60.0);
    [self.draft setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.draft setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.draft.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.draft setTitle:@"送风" forState:UIControlStateNormal];
    [self.draft addTarget:self action:@selector(allRunModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.draft];
    
    self.automatic = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.automatic.frame = CGRectMake(self.segmentContainer.width/3*2 - 30.0, CGRectGetMaxY(self.hot.frame) + 20.0, 60.0, 60.0);
    [self.automatic setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.automatic setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.automatic.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.automatic setTitle:@"自动" forState:UIControlStateNormal];
    [self.automatic addTarget:self action:@selector(allRunModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.automatic];
    
    [self trackRunModeSubButtonStatus];
}

/**
 跟踪显示场景模式下按钮的选中状态
 */
-(void)trackRunModeSubButtonStatus
{
    if (self.device.valRunMode == 0)// 制热
    {
        self.hot.selected = YES;
        self.cold.selected = NO;
        self.dehumidifier.selected = NO;
        self.draft.selected = NO;
        self.automatic.selected = NO;
    }
    else if (self.device.valRunMode == 1)// 制冷
    {
        self.hot.selected = NO;
        self.cold.selected = YES;
        self.dehumidifier.selected = NO;
        self.draft.selected = NO;
        self.automatic.selected = NO;
    }
    else if (self.device.valRunMode == 2)// 换气
    {
        self.hot.selected = NO;
        self.cold.selected = NO;
        self.dehumidifier.selected = NO;
        self.draft.selected = YES;
        self.automatic.selected = NO;
    }
    else if (self.device.valRunMode == 3)// 自动
    {
        self.hot.selected = NO;
        self.cold.selected = NO;
        self.dehumidifier.selected = NO;
        self.draft.selected = NO;
        self.automatic.selected = YES;
    }
    else if (self.device.valRunMode == 4)// 除湿
    {
        self.hot.selected = NO;
        self.cold.selected = NO;
        self.dehumidifier.selected = YES;
        self.draft.selected = NO;
        self.automatic.selected = NO;
    }
}

- (void)changeRunModelStatusWithButton:(UIButton *)button
{
    // 对应关系为：0-制热，1-制冷，2-换气，3-自动，4-除湿。
    if (button == self.allRunModelButton)
    {
        if (self.device.valRunMode == 0)
        {
            // 制热
            self.hot.selected = YES;
            self.assistantHeat.enabled = YES;
            self.cold.selected = self.dehumidifier.selected = self.draft.selected = self.automatic.selected = NO;
        }
        else if (self.device.valRunMode == 1)
        {
            // 制冷
            self.cold.selected = YES;
//            self.assistantHeat.enabled = NO;
            self.hot.selected = self.dehumidifier.selected = self.draft.selected = self.automatic.selected = NO;
        }
        else if (self.device.valRunMode == 2)
        {
            // 换气
            self.draft.selected = YES;
//            self.assistantHeat.enabled = NO;
            self.hot.selected = self.cold.selected = self.dehumidifier.selected = self.automatic.selected = NO;
        }
        else if (self.device.valRunMode == 3)
        {
            // 自动
            self.automatic.selected = YES;
//            self.assistantHeat.enabled = NO;
            self.hot.selected = self.cold.selected = self.draft.selected = self.dehumidifier.selected = NO;
        }
        else if (self.device.valRunMode == 4)
        {
            // 除湿
            self.dehumidifier.selected = YES;
//            self.assistantHeat.enabled = NO;
            self.hot.selected = self.cold.selected = self.draft.selected = self.automatic.selected = NO;
        }
    }
}

- (void)allRunModelSubButtonSelected:(UIButton *)button
{
    [self canSoundOrVibratePlay];
    
    if (self.device.stPower == 0)
    {
        return;
    }
    
    if (button == self.hot)
    {
        self.hot.selected = YES;
        self.cold.selected = self.dehumidifier.selected = self.draft.selected = self.automatic.selected = NO;
        
        // 发送制热命令
        [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(0)];
    }
    else if (button == self.cold)
    {
        self.cold.selected = YES;
        self.hot.selected = self.dehumidifier.selected = self.draft.selected = self.automatic.selected = NO;
        
        // 发送制冷命令
        [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(1)];
    }
    else if (button == self.draft)
    {
        self.draft.selected = YES;
        self.hot.selected = self.cold.selected = self.dehumidifier.selected = self.automatic.selected = NO;
        
        // 发送换气命令
        [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(2)];
    }
    else if (button == self.automatic)
    {
        self.automatic.selected = YES;
        self.hot.selected = self.cold.selected = self.draft.selected = self.dehumidifier.selected = NO;
        
        // 发送自动命令
        [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(3)];
    }
    else if (button == self.dehumidifier)
    {
        self.dehumidifier.selected = YES;
        self.hot.selected = self.cold.selected = self.draft.selected = self.automatic.selected = NO;
        
        // 发送除湿命令
        [XLDMITools commandStrCmdWith:@"setRunningMode" withStrIndex:self.strIndex withValue:@(4)];
    }
}
#pragma mark - 模式相关设置
#pragma mark -

#pragma mark - 风速相关设置
#pragma mark -
-(void)initFanSpeedModelSegmentSubViews
{
    CGFloat x = self.segmentContainer.width / 8;
    
    self.smallWind = [UIButton buttonWithType:UIButtonTypeCustom];//1
    self.smallWind.frame = CGRectMake(x * 0.25, (self.segmentContainer.height - 60.0)/4 - 10.0, 60.0, 60.0);
    [self.smallWind setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.smallWind setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.smallWind.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.smallWind setTitle:@"低风" forState:UIControlStateNormal];
    [self.smallWind addTarget:self action:@selector(allFanSpeedModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.smallWind];
    
    self.middleWind = [UIButton buttonWithType:UIButtonTypeCustom];//2
    self.middleWind.frame = CGRectMake(x * 2.5, (self.segmentContainer.height - 60.0)/4 - 10.0, 60.0, 60.0);
    [self.middleWind setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.middleWind setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.middleWind.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.middleWind setTitle:@"中风" forState:UIControlStateNormal];
    [self.middleWind addTarget:self action:@selector(allFanSpeedModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.middleWind];
    
    self.bigWind = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.bigWind.frame = CGRectMake(x * 4.5, (self.segmentContainer.height - 60.0)/4 - 10.0, 60.0, 60.0);
    [self.bigWind setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.bigWind setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.bigWind.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.bigWind setTitle:@"高风" forState:UIControlStateNormal];
    [self.bigWind addTarget:self action:@selector(allFanSpeedModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.bigWind];
    
    self.autoWind = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.autoWind.frame = CGRectMake(x * 6.5, (self.segmentContainer.height - 60.0)/4 - 10.0, 60.0, 60.0);
    [self.autoWind setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.autoWind setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.autoWind.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.autoWind setTitle:@"自动" forState:UIControlStateNormal];
    [self.autoWind addTarget:self action:@selector(allFanSpeedModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.autoWind];
    
    self.verticalWind = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.verticalWind.frame = CGRectMake(self.segmentContainer.width/3 - 30.0, CGRectGetMaxY(self.smallWind.frame) + 20.0, 60.0, 60.0);
    [self.verticalWind setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.verticalWind setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.verticalWind.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.verticalWind setTitle:@"垂直\n摆风" forState:UIControlStateNormal];
    self.verticalWind.titleLabel.lineBreakMode = 0;
    [self.verticalWind addTarget:self action:@selector(allFanSpeedModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.verticalWind];
    
    self.horizontalWind = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.horizontalWind.frame = CGRectMake(self.segmentContainer.width/3*2 - 30.0, CGRectGetMaxY(self.smallWind.frame) + 20.0, 60.0, 60.0);
    [self.horizontalWind setBackgroundImage:[UIImage imageNamed:@"device_state_off"] forState:UIControlStateNormal];
    [self.horizontalWind setBackgroundImage:[UIImage imageNamed:@"device_state_on"] forState:UIControlStateSelected];
    self.horizontalWind.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.horizontalWind setTitle:@"水平\n摆风" forState:UIControlStateNormal];
    self.horizontalWind.titleLabel.lineBreakMode = 0;
    [self.horizontalWind addTarget:self action:@selector(allFanSpeedModelSubButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.segmentContainer addSubview:self.horizontalWind];
    
    [self trackRunModeSubButtonStatus];
}

/**
 跟踪显示场景模式下按钮的选中状态
 */
-(void)trackFanSpeedSubButtonStatus
{
    // 风向 * 16 + 风速
    if (self.device.valFanSpeed == 0x00)
    {
        self.smallWind.selected = YES;
        self.middleWind.selected = self.bigWind.selected = self.autoWind.selected = self.verticalWind.selected = self.horizontalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x01)
    {
        self.middleWind.selected = YES;
        self.smallWind.selected = self.bigWind.selected = self.autoWind.selected = self.verticalWind.selected = self.horizontalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x02)
    {
        self.bigWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.autoWind.selected = self.verticalWind.selected = self.horizontalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x03)
    {
        self.autoWind.selected = YES;
        self.smallWind.selected = self.bigWind.selected = self.middleWind.selected = self.verticalWind.selected = self.horizontalWind.selected = NO;
    }
    //
    else if (self.device.valFanSpeed == 0x10)
    {
        self.verticalWind.selected = YES;
        self.smallWind.selected = YES;
        self.middleWind.selected = self.bigWind.selected = self.autoWind.selected = self.horizontalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x11)
    {
        self.verticalWind.selected = YES;
        self.middleWind.selected = YES;
        self.smallWind.selected = self.bigWind.selected = self.autoWind.selected = self.horizontalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x12)
    {
        self.verticalWind.selected = YES;
        self.bigWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.autoWind.selected = self.horizontalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x13)
    {
        self.verticalWind.selected = YES;
        self.autoWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.bigWind.selected = self.horizontalWind.selected = NO;
    }
    //
    else if (self.device.valFanSpeed == 0x20)
    {
        self.horizontalWind.selected = YES;
        self.smallWind.selected = YES;
        self.middleWind.selected = self.bigWind.selected = self.autoWind.selected = self.verticalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x21)
    {
        self.horizontalWind.selected = YES;
        self.middleWind.selected = YES;
        self.smallWind.selected = self.bigWind.selected = self.autoWind.selected = self.verticalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x22)
    {
        self.horizontalWind.selected = YES;
        self.bigWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.autoWind.selected = self.verticalWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x23)
    {
        self.horizontalWind.selected = YES;
        self.autoWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.bigWind.selected = self.verticalWind.selected = NO;
    }
    //
    //
    else if (self.device.valFanSpeed == 0x30)
    {
        self.horizontalWind.selected = YES;
        self.verticalWind.selected = YES;
        self.smallWind.selected = YES;
        self.middleWind.selected = self.bigWind.selected = self.autoWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x31)
    {
        self.horizontalWind.selected = YES;
        self.verticalWind.selected = YES;
        self.middleWind.selected = YES;
        self.smallWind.selected = self.bigWind.selected = self.autoWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x32)
    {
        self.horizontalWind.selected = YES;
        self.verticalWind.selected = YES;
        self.bigWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.autoWind.selected = NO;
    }
    else if (self.device.valFanSpeed == 0x33)
    {
        self.horizontalWind.selected = YES;
        self.verticalWind.selected = YES;
        self.autoWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.bigWind.selected = NO;
    }
}

- (void)allFanSpeedModelSubButtonSelected:(UIButton *)button
{
    [self canSoundOrVibratePlay];
    
    if (self.device.stPower == 0)
    {
        return;
    }
    
    if (button == self.smallWind)
    {
        self.smallWind.selected = YES;
        self.middleWind.selected = self.bigWind.selected = self.autoWind.selected = NO;
        
        self.fanSpeed = 0;
    }
    else if (button == self.middleWind)
    {
        self.middleWind.selected = YES;
        self.smallWind.selected = self.bigWind.selected = self.autoWind.selected = NO;
        
        self.fanSpeed = 1;
    }
    else if (button == self.bigWind)
    {
        self.bigWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.autoWind.selected = NO;
        
        self.fanSpeed = 2;
    }
    else if (button == self.autoWind)
    {
        self.autoWind.selected = YES;
        self.smallWind.selected = self.middleWind.selected = self.bigWind.selected = NO;
        
        self.fanSpeed = 3;
    }
    else if(button == self.verticalWind)
    {
        self.verticalWind.selected = !self.verticalWind.selected;
        
        self.fanDirection = 1;
    }
    else if(button == self.horizontalWind)
    {
        self.horizontalWind.selected = !self.horizontalWind.selected;
        
        self.fanDirection = 2;
    }
    
    [self calculateFanSpeedCmdValue];
    
    [XLDMITools commandStrCmdWith:@"setFanSpeed" withStrIndex:self.strIndex withValue:@(self.fanIndex)];
}

- (int)calculateFanSpeedCmdValue
{
    // 风向 * 16 + 风速
    if (self.smallWind.selected)
    {
        self.fanSpeed = 0;
    }
    else if (self.middleWind.selected)
    {
        self.fanSpeed = 1;
    }
    else if (self.bigWind.selected)
    {
        self.fanSpeed = 2;
    }
    else if (self.autoWind.selected)
    {
        self.fanSpeed = 3;
    }
    
    int a;
    if (self.verticalWind.selected && self.horizontalWind.selected)
    {
        a = 3;
    }
    else if (!self.verticalWind.selected && self.horizontalWind.selected)
    {
        a = 2;
    }
    else if (self.verticalWind.selected && !self.horizontalWind.selected)
    {
        a = 1;
    }
    else
    {
        a = 0;
    }
    
    self.fanIndex = self.fanSpeed + a * 16;
    return self.fanIndex;
}

/**
 风速选择
 */
- (void)allFanSpeedButtonSelected:(UIButton *)button
{
    
}
#pragma mark - 风速相关设置
#pragma mark -

#pragma mark - 状态相关设置
#pragma mark -
-(void)initStatusModelSegmentSubViews
{
    self.statusRightOrError = [UIButton buttonWithType:UIButtonTypeCustom];
    self.statusRightOrError.frame = CGRectMake(self.segmentContainer.width/3 - 22.5, (self.segmentContainer.height - 60.0)/4, 45.0, 45.0);
    self.statusRightOrError.userInteractionEnabled = NO;
    [self.segmentContainer addSubview:self.statusRightOrError];
    
    self.statusMsgRightOrError = [UIButton buttonWithType:UIButtonTypeCustom];//2
    self.statusMsgRightOrError.frame = CGRectMake(self.segmentContainer.width/3*2 - 50.0, (self.segmentContainer.height - 60.0)/4, 100.0, 45.0);
    self.statusMsgRightOrError.userInteractionEnabled = NO;
    self.statusMsgRightOrError.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.segmentContainer addSubview:self.statusMsgRightOrError];
    
    if (self.device.stError == 0)
    {
        [self.statusRightOrError setBackgroundImage:[UIImage imageNamed:@"status_right"] forState:UIControlStateNormal];
        [self.statusMsgRightOrError setBackgroundImage:[UIImage imageNamed:@"status_error_msgbg_no"] forState:UIControlStateNormal];
        [self.statusMsgRightOrError setTitle:@"无故障" forState:UIControlStateNormal];
    }
    else
    {
        [self.statusRightOrError setBackgroundImage:[UIImage imageNamed:@"status_error"] forState:UIControlStateNormal];
        [self.statusMsgRightOrError setBackgroundImage:[UIImage imageNamed:@"status_error_msgbg"] forState:UIControlStateNormal];
        
//        我告诉你算法吧。
//        61011 % 256，就是 83
//        61011 / 256 = 238， 转成16进制，是0xEE
//        "EE" = printf("%02X", 61011 / 256);
        NSLog(@"%02X",61011/256);
        NSString *errorCode = [NSString stringWithFormat:@"故障码 %02X-%zd",self.device.stError/256,self.device.stError%256];
        [self.statusMsgRightOrError setTitle:errorCode forState:UIControlStateNormal];
    }
    
    self.statusMotorOnOrOff = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.statusMotorOnOrOff.frame = CGRectMake(self.segmentContainer.width/3 - 30.0, CGRectGetMaxY(self.statusRightOrError.frame) + 20.0, 60.0, 60.0);
    self.statusMotorOnOrOff.userInteractionEnabled = NO;
    [self.segmentContainer addSubview:self.statusMotorOnOrOff];
    
    self.statusIceOnOrOff = [UIButton buttonWithType:UIButtonTypeCustom];//4
    self.statusIceOnOrOff.frame = CGRectMake(self.segmentContainer.width/3*2 - 30.0, CGRectGetMaxY(self.statusRightOrError.frame) + 20.0, 60.0, 60.0);
    self.statusIceOnOrOff.userInteractionEnabled = NO;
    [self.segmentContainer addSubview:self.statusIceOnOrOff];
    
    if (self.device.stHost == 0)
    {
        [self.statusMotorOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_motor_off"] forState:UIControlStateNormal];
        [self.statusIceOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_ice_off"] forState:UIControlStateNormal];
    }
    else if (self.device.stHost == 1)
    {
        [self.statusMotorOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_motor_off"] forState:UIControlStateNormal];
        [self.statusIceOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_ice_on"] forState:UIControlStateNormal];
    }
    else if (self.device.stHost == 2)
    {
        [self.statusMotorOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_motor_on"] forState:UIControlStateNormal];
        [self.statusIceOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_ice_off"] forState:UIControlStateNormal];
    }
    else if (self.device.stHost == 3)
    {
        [self.statusMotorOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_motor_on"] forState:UIControlStateNormal];
        [self.statusIceOnOrOff setBackgroundImage:[UIImage imageNamed:@"status_ice_on"] forState:UIControlStateNormal];
    }
    
    [self trackRunModeSubButtonStatus];
}
/**
 状态选择
 */
- (void)allStatusButtonSelected:(UIButton *)button
{
    
}
#pragma mark - 状态相关设置
#pragma mark -

-(void)canSoundOrVibratePlay
{
    XLAppDelegate *appDelegate = (XLAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.canSoundPlay)
    {
        // 开始播放\继续播放
        [appDelegate.player play];
        [ECMusicTool stopMusic:appDelegate.songs[1]];
        [ECMusicTool playMusic:appDelegate.songs[1]];
    }
    
    if (appDelegate.canVibratePlay)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

//按钮转换模式
- (void)allButtonSelected2:(UIButton *)button
{
    if (button == self.allWorkModelButton)
    {
        if(self.isStatusForFive){
            [self changeFrameForThreeBtn];
        }
        self.allWorkModelButton.selected = YES;
        self.allRunModelButton.selected = NO;
        self.allFanSpeedButton.selected = NO;
        self.allFour.hidden = YES;
        self.allFive.hidden = YES;
        [self changeButtonStatusWithButton:button];
    }
    else if (button == self.allRunModelButton)
    {
        if(self.isStatusForFive){
            [self changeFrameForThreeBtnUp];
            self.allFour.hidden = NO;
            self.allFive.hidden = NO;
        }
        self.allWorkModelButton.selected = NO;
        self.allRunModelButton.selected = YES;
        self.allFanSpeedButton.selected = NO;
        [self changeButtonStatusWithButton:button];
    }
    else if (button == self.allFanSpeedButton)
    {
        if(self.isStatusForFive){
            [self changeFrameForThreeBtn];
        }
        self.allWorkModelButton.selected = NO;
        self.allRunModelButton.selected = NO;
        self.allFanSpeedButton.selected = YES;
        self.allFour.hidden = YES;
        self.allFive.hidden = YES;
        [self changeButtonStatusWithButton:button];
    }
}
//按钮实现方法
- (void)changeButtonStatusWithButton:(UIButton *)button
{
    XLAppDelegate *appDelegate = (XLAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.canSoundPlay)
    {
        // 开始播放\继续播放
        [appDelegate.player play];
        [ECMusicTool stopMusic:appDelegate.songs[1]];
        [ECMusicTool playMusic:appDelegate.songs[1]];
    }
    
    if (appDelegate.canVibratePlay)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if (button == self.allWorkModelButton)
    {
        [self.allFirst setTitle:@"恒温" forState:UIControlStateNormal];
        [self.allSecond setTitle:@"节能" forState:UIControlStateNormal];
        [self.allThird setTitle:@"离家" forState:UIControlStateNormal];
        
        if (self.device.valWorkMode == 0)
        {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
        }
        else if (self.device.valWorkMode == 1)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
        }
        else if (self.device.valWorkMode == 2)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
        }
    }
    else if (button == self.allRunModelButton)
    {
        [self.allFirst setTitle:@"制冷" forState:UIControlStateNormal];
        [self.allSecond setTitle:@"制热" forState:UIControlStateNormal];
        [self.allThird setTitle:@"换气" forState:UIControlStateNormal];
        [self.allFour setTitle:@"空调\n制热" forState:UIControlStateNormal];
        self.allFour.titleLabel.lineBreakMode = 0;
        [self.allFive setTitle:@"暖气\n制热" forState:UIControlStateNormal];
        self.allFive.titleLabel.lineBreakMode = 0;
        if (self.device.valRunMode == 1)
        {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
            self.allFour.selected = NO;
            self.allFive.selected = NO;
        }
        else if (self.device.valRunMode == 0)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = YES;
            self.allFive.selected = YES;
        }
        else if (self.device.valRunMode == 2)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
            self.allFour.selected = NO;
            self.allFive.selected = NO;
        }
        else if (self.device.valRunMode == 5)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = YES;
            self.allFive.selected = NO;
        }
        else if (self.device.valRunMode == 4)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
            self.allFour.selected = NO;
            self.allFive.selected = YES;
        }
        
    }
    else if (button == self.allFanSpeedButton)
    {
        [self.allFirst setTitle:@"低风" forState:UIControlStateNormal];
        [self.allSecond setTitle:@"中风" forState:UIControlStateNormal];
        [self.allThird setTitle:@"高风" forState:UIControlStateNormal];
        
        
        if (self.device.valFanSpeed == 0 || self.device.valFanSpeed % 16 == 0)
        {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
        }
        else if (self.device.valFanSpeed == 1 || self.device.valFanSpeed % 16 == 1)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = YES;
            self.allThird.selected = NO;
        }
        else if (self.device.valFanSpeed == 2 || self.device.valFanSpeed % 16 == 2)
        {
            self.allFirst.selected = NO;
            self.allSecond.selected = NO;
            self.allThird.selected = YES;
        } else {
            self.allFirst.selected = YES;
            self.allSecond.selected = NO;
            self.allThird.selected = NO;
        }
    }
}
- (void)changeFrameForThreeBtn {
    self.allFirst.frame= CGRectMake(30.0, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2, 60.0, 60.0);
    self.allSecond.frame= CGRectMake((kMainScreenSizeWidth - 20 - 60)/2, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2, 60.0, 60.0);
    self.allThird.frame = CGRectMake(kMainScreenSizeWidth - 10 - 100.0, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2, 60.0, 60.0);
}
- (void)changeFrameForThreeBtnUp {
    self.allFirst.frame= CGRectMake(30.0, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2-40, 60.0, 60.0);
    self.allSecond.frame= CGRectMake((kMainScreenSizeWidth - 20 - 60)/2, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2-40, 60.0, 60.0);
    self.allThird.frame = CGRectMake(kMainScreenSizeWidth - 10 - 100.0, ((kMainScreenSizeWidth - 20)/2 - 60.0)/2-40, 60.0, 60.0);
}

@end
