//
//  PSWriteFeedbackViewController.m
//  PrisonService
//
//  Created by calvin on 2018/4/16.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSWriteFeedbackViewController.h"
#import "UITextView+Placeholder.h"
#import "FeedbackCell.h"
#import "FeedloadImgView.h"
#import "ReactiveObjC.h"
#import "PSFWriteFeedSuccessViewController.h"
#import "FeedbackTypeModel.h"
#import "PSRegisterViewModel.h"
#import "NSString+emoji.h"

@interface PSWriteFeedbackViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    UIButton*submitBtn;
}

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UITextView  *contentTextView;
@property (nonatomic, strong) UILabel *countLab; //字数
@property (nonatomic, assign) NSInteger selecldIndex;
@property (nonatomic, strong) NSMutableArray *imageUrls;
@property (nonatomic, assign) BOOL feedbackSucess;

@end

@implementation PSWriteFeedbackViewController
- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
        NSString *feedback=NSLocalizedString(@"feedback", @"意见反馈");
        if (feedbackViewModel.writefeedType == PSPrisonfeedBack) {
                feedback=NSLocalizedString(@"complain_advice", @"投诉建议");
        }
        self.title = feedback;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFeedbackTypes {
    
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    @weakify(self)
    [[PSLoadingView sharedInstance] show];
    [feedbackViewModel sendFeedbackTypesCompleted:^(PSResponse *response) {
        @strongify(self)
        if (response.code == 200) {
            [self.tableview reloadData];
        }else{
            NSString *msg = NSLocalizedString(@"Get feedback suggestion feedback category failed", @"获取反馈建议反馈类别失败");
           [PSTipsView showTips:response.msg ? response.msg : msg];
        }
        [[PSLoadingView sharedInstance] dismiss];
    } failed:^(NSError *error) {
        @strongify(self)
        [self showNetError:error];
        [[PSLoadingView sharedInstance] dismiss];
    }];
    
}
- (void)sendFeedback {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    @weakify(self)
    [[PSLoadingView sharedInstance] show];
    [feedbackViewModel sendFeedbackCompleted:^(PSResponse *response) {
        [[PSLoadingView sharedInstance] dismiss];
        submitBtn.enabled = YES;
        @strongify(self)
        if (response.code == 200) {
            self.feedbackSucess = YES; //反馈成功
            PSFWriteFeedSuccessViewController *storageViewController = [[PSFWriteFeedSuccessViewController alloc] initWithViewModel:self.viewModel];
            [self.navigationController pushViewController:storageViewController animated:YES];
            KPostNotification(@"wirtefeedListfresh", nil);
            //刷新列表
            
        }else{
            NSString *msg = NSLocalizedString(@"submission Failed", @"提交失败");
            [PSTipsView showTips:response.msg ? response.msg :msg];
        }
    } failed:^(NSError *error) {
        @strongify(self)
        submitBtn.enabled = YES;
        [[PSLoadingView sharedInstance] dismiss];
        [self showNetError:error];
    }];
}

- (void)submitContent {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
     FeedbackTypeModel *typeModel = feedbackViewModel.reasons[self.selecldIndex];
    feedbackViewModel.type = typeModel.id;
    feedbackViewModel.content = _contentTextView.text;
    if (self.imageUrls.count>0) {
        NSString *imageUrl = @"";
        for (NSString *url in self.imageUrls) {
            imageUrl = [NSString stringWithFormat:@"%@;%@",imageUrl,url];
        }
        if ([imageUrl hasPrefix:@";"]) {
            imageUrl = [imageUrl substringFromIndex:1];
        }
        feedbackViewModel.imageUrls = imageUrl;
        NSLog(@"%@",imageUrl);
    } else {
        feedbackViewModel.imageUrls = @"";
    }
    
    @weakify(self)
    [feedbackViewModel checkDataWithCallback:^(BOOL successful, NSString *tips) {
        @strongify(self)
        if (successful) {
            [self sendFeedback];
        }else{
            [PSTipsView showTips:tips];
            submitBtn.enabled = YES;
        }
    }];
}

- (void)renderContents {
    CGFloat horizontalSpace = 15;
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = FontOfSize(27);
    titleLabel.textColor = UIColorFromHexadecimalRGB(0x333333);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    NSString*feedback=NSLocalizedString(@"feedback", @"意见反馈");
    titleLabel.text = feedback;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(horizontalSpace);
        make.left.mas_equalTo(horizontalSpace);
        make.right.mas_equalTo(-horizontalSpace);
        make.height.mas_equalTo(30);
    }];
    
    self.contentTextView = [UITextView new];
    self.contentTextView.font = FontOfSize(12);
    self.contentTextView.delegate = self;
    NSString*input_yourfeedback=NSLocalizedString(@"input_yourfeedback", @"请输入您的意见反馈");
    self.contentTextView.placeholder = input_yourfeedback;
    [self.view addSubview:self.contentTextView];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(200);
    }];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton addTarget:self action:@selector(submitContent) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = AppBaseTextFont1;
    UIImage *bgImage = [UIImage imageNamed:@"universalBtGradientBg"];
    [submitButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString*submit=NSLocalizedString(@"submit", @"提交");
    [submitButton setTitle:submit forState:UIControlStateNormal];
    [self.view addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(bgImage.size);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self renderContents];
    self.view.backgroundColor = AppBaseBackgroundColor2;
    self.selecldIndex = 0;
    self.feedbackSucess = NO; //默认没有反馈
    [self getFeedbackTypes];
    [self p_setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
    
}

//复用返回-->如果没提交且图片书桌有内容上传图片
- (IBAction)actionOfLeftItem:(id)sender {
    if (self.imageUrls.count>0&&self.feedbackSucess==NO) {
        PSFeedbackViewModel *viewModel = (PSFeedbackViewModel *)self.viewModel;
        viewModel.urls = self.imageUrls;
        [viewModel requestdeleteFinish:^(id responseObject) {
            
        } enError:^(NSError *error) {
            
        }];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods

- (void)p_setUI {
    
    [self.view addSubview:self.scrollview];
    
    UIView *oneView = [[UIView alloc] initWithFrame:CGRectMake(0,20 ,SCREEN_WIDTH,195)];
    oneView.backgroundColor = [UIColor clearColor];
    oneView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    oneView.layer.shadowOffset = CGSizeMake(0,3);
    oneView.layer.shadowOpacity = 1;
    oneView.layer.shadowRadius = 4;
    [self.scrollview addSubview:oneView];
    [oneView addSubview:self.tableview];

 
    
    UIView *secondeView = [[UIView alloc] initWithFrame:CGRectMake(0,oneView.bottom+18,self.scrollview.width, 160)];
    secondeView.backgroundColor = [UIColor whiteColor];
    secondeView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    secondeView.layer.shadowOffset = CGSizeMake(0,3);
    secondeView.layer.shadowOpacity = 1;
    secondeView.layer.shadowRadius = 4;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(18,8,secondeView.width-48, 30)];
    NSString *titleStr = NSLocalizedString(@"Please add detailed questions and comments", @"请补充详细问题和意见");
    titleLab.text = titleStr;
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.textColor = UIColorFromRGB(51, 51, 51);
    titleLab.font = FontOfSize(12);
    [secondeView addSubview:titleLab];
    
    UIView *headLine = [[UIView alloc] initWithFrame:CGRectMake(15,titleLab.bottom+4, secondeView.width-30, 1)];
    headLine.backgroundColor = UIColorFromRGB(234, 235, 238);
    [secondeView addSubview:headLine];
    
    self.contentTextView.frame = CGRectMake(15,headLine.bottom+8,secondeView.width-30, 100);
    [secondeView addSubview:self.contentTextView];
    
    self.countLab.frame = CGRectMake(secondeView.width-75,secondeView.height-25, 60, 21);
    [secondeView addSubview:self.countLab];
    
    UIView *thirdView = [[UIView alloc] initWithFrame:CGRectMake(0, secondeView.bottom+18,self.scrollview.width, 130)];
    thirdView.backgroundColor = [UIColor whiteColor];
    thirdView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    thirdView.layer.shadowOffset = CGSizeMake(0,3);
    thirdView.layer.shadowOpacity = 1;
    thirdView.layer.shadowRadius = 4;
    [self.scrollview addSubview:thirdView];

    UILabel *thirdTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(18,8,secondeView.width-48, 30)];

    NSString *thirdTitleStr = NSLocalizedString(@"Please provide screenshots or photos of related questions (up to 4)", @"请提供相关问题的截图或照片（最多4张）");
    thirdTitleLab.text = thirdTitleStr;
    thirdTitleLab.numberOfLines = 0;
    thirdTitleLab.textAlignment = NSTextAlignmentLeft;
    thirdTitleLab.textColor = UIColorFromRGB(51, 51, 51);
    thirdTitleLab.font = FontOfSize(12);
    [thirdView addSubview:thirdTitleLab];


    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    FeedloadImgView *loadImg = [[FeedloadImgView alloc] initWithFrame:CGRectMake(0,thirdTitleLab.bottom, thirdView.width,100) count:4 feedType:feedbackViewModel.writefeedType];
    [thirdView addSubview:loadImg];
    loadImg.feedloadResultBlock = ^(NSMutableArray *result) {
        self.imageUrls = result;
    };
    [self.scrollview addSubview:secondeView];
    submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(15,self.scrollview.bottom+13,self.view.width-30, 44);
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius= 4;
    NSString*submit=NSLocalizedString(@"submit", @"提交");
    [submitBtn setTitle:submit forState:UIControlStateNormal];
    submitBtn.backgroundColor = UIColorFromRGB(83, 119, 185);
    [self.view addSubview:submitBtn];
    [submitBtn bk_whenTapped:^{
        submitBtn.enabled = NO;
        [self submitContent];
    }];
}

#pragma mark - Delegate
#pragma mark  UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    PSFeedbackViewModel *feedbackViewModel = (PSFeedbackViewModel *)self.viewModel;
    feedbackViewModel.content = textView.text;
    if ([NSString hasEmoji:textView.text]||[NSString stringContainsEmoji:textView.text]) {
        NSString *msg = NSLocalizedString(@"Can't enter expressions!", @"不能输入表情！");
        [PSTipsView showTips:msg];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isFirstResponder]) {

        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            NSString *msg = NSLocalizedString(@"Can't enter expressions!", @"不能输入表情！");
            [PSTipsView showTips:msg];
            return NO;
        }
        //判断键盘是不是九宫格键盘
        if ([NSString isNineKeyBoard:text] ){
            return YES;
        }else{
            if ([NSString hasEmoji:text] || [NSString stringContainsEmoji:text]){
                NSString *msg = NSLocalizedString(@"Can't enter expressions!", @"不能输入表情！");
                [PSTipsView showTips:msg];
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark UITableViewDelegate&&UITableViewDatalist
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSFeedbackViewModel *viewModel = (PSFeedbackViewModel *)self.viewModel;
    return viewModel.reasons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedbackCell *cell = [[FeedbackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FeedbackCell"];
    PSFeedbackViewModel *viewModel = (PSFeedbackViewModel *)self.viewModel;
    FeedbackTypeModel *typeModel = viewModel.reasons[indexPath.row];
    NSString *title = typeModel.desc?[NSString stringWithFormat:@"%@: %@",typeModel.name,typeModel.desc]:typeModel.name;
    cell.titleLab.text = title;
    if (indexPath.row == viewModel.reasons.count-1) cell.lineImg.hidden = YES;
    if (self.selecldIndex == indexPath.row) {
        cell.seleImg.image = [UIImage imageNamed:@"writeFeedsel"];
    } else {
        cell.seleImg.image = [UIImage imageNamed:@"writeFeednosel"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selecldIndex = indexPath.row;
    [self.tableview reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [UIView new];
    headView.frame = CGRectMake(0, 0,tableView.width, 44);
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, (headView.height-30)/2,headView.width-20, 30)];
    NSString *titleStr = NSLocalizedString(@"(single choice) Please select the problem you want to feedback.", @"（单选）请选择您想反馈的问题点");
    titleLab.text = titleStr;
    titleLab.font = FontOfSize(12);
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.textColor = UIColorFromRGB(51, 51, 51);
    
    UIView *headLine = [[UIView alloc] initWithFrame:CGRectMake(20,headView.height-1, headView.width-40, 1)];
    headLine.backgroundColor = UIColorFromRGB(234, 235, 238);
    [headView addSubview:headLine];
    [headView addSubview:titleLab];
    return headView;
}

#pragma mark Setting&&Getting
- (UIScrollView *)scrollview {
    if (!_scrollview) {
         _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT-kTopHeight-44-30)];
        _scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    return _scrollview;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,195)];
        [_tableview registerClass:[FeedbackCell class] forCellReuseIdentifier:@"FeedbackCell"];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.scrollEnabled = NO;
    }
    return _tableview;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        NSString *less_msg = NSLocalizedString(@"Please enter a description of no less than 10 words", @"请输入不少于10个字的描述");
        NSString *more_msg = NSLocalizedString(@"Please enter a description of no more than 300 words", @"请输入不多于300个字的描述");
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.placeholder = less_msg;
        _contentTextView.delegate = self;
        @weakify(self);
        [_contentTextView.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            if (x.length>300) {
                _contentTextView.text = [x substringToIndex:299];
                [PSTipsView showTips:more_msg];
            }
            self.countLab.text = [NSString stringWithFormat:@"%lu/300",(unsigned long)_contentTextView.text.length];
        }];
    }
    return _contentTextView;
}

- (UILabel *)countLab {
    if (!_countLab) {
        _countLab = [[UILabel alloc] init];
        _countLab.text = @"0/300";
        _countLab.textColor = UIColorFromRGB(153, 153, 153);
        _countLab.font = FontOfSize(11);
        _countLab.textAlignment = NSTextAlignmentRight;
    }
    return _countLab;
}

- (NSMutableArray *)imageUrls {
    if (!_imageUrls) {
        _imageUrls = [NSMutableArray array];
    }
    return _imageUrls;
}





@end
