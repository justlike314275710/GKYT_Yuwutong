//
//  PSLocalHistoryViewContller.m
//  PrisonService
//
//  Created by kky on 2019/6/4.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSLocalHistoryViewContller.h"
#import "MJRefresh.h"
#import "NSString+Date.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PSHistoryCell.h"
#import "PSTipsConstants.h"
#import "PSLocalMeetingHistoryViewModel.h"
#import "PSMeettingHistory.h"
#import "PSCancelReasonView.h"

@interface PSLocalHistoryViewContller ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic , strong) UITableView*historyTableView;

@end

@implementation PSLocalHistoryViewContller


- (instancetype)initWithViewModel:(PSViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        NSString*userCenterHistory=NSLocalizedString(@"userCenterHistory", @"实地会见历史");
        self.title = userCenterHistory;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderContents];
    [self refreshData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadMore {
    PSLocalMeetingHistoryViewModel *meetingHistoryModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    @weakify(self)
    [meetingHistoryModel loadMoreRefundCompleted:^(PSResponse *response) {
        @strongify(self)
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [self reloadContents];
    }];
}
- (void)refreshData {
    PSLocalMeetingHistoryViewModel *meetingHistoryModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    [[PSLoadingView sharedInstance]show];
    @weakify(self)
    
    [meetingHistoryModel refreshRefundCompleted:^(PSResponse *response) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    } failed:^(NSError *error) {
        @strongify(self)
        [[PSLoadingView sharedInstance] dismiss];
        [self reloadContents];
    }];
}

- (void)reloadContents {
    PSLocalMeetingHistoryViewModel *meetingHistoryModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    if (meetingHistoryModel.hasNextPage) {
        @weakify(self)
        self.historyTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self loadMore];
        }];
    }else{
        self.historyTableView.mj_footer = nil;
    }
    [self.historyTableView.mj_header endRefreshing];
    [self.historyTableView.mj_footer endRefreshing];
    [self.historyTableView reloadData];
}
- (void)renderContents {
    self.view.backgroundColor=[UIColor whiteColor];
    self.historyTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.historyTableView.dataSource = self;
    self.historyTableView.delegate = self;
    self.historyTableView.emptyDataSetSource = self;
    self.historyTableView.emptyDataSetDelegate = self;
    self.historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.historyTableView.backgroundColor = [UIColor clearColor];
    @weakify(self)
    self.historyTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self refreshData];
    }];
    [self.historyTableView registerClass:[PSHistoryCell class] forCellReuseIdentifier:@"PSHistoryCell"];
    self.historyTableView.tableFooterView = [UIView new];
    [self.view addSubview:self.historyTableView];
    
    [self.historyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-49-kTopHeight-35-14);
        //make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PSLocalMeetingHistoryViewModel *meetingHistoryModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    return meetingHistoryModel.meeetHistorys.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSLocalMeetingHistoryViewModel *meetingHistoryModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    PSMeettingHistory *MeettingHistory= meetingHistoryModel.meeetHistorys[indexPath.row];
    NSString *str = MeettingHistory.remarks ;//你想显示的字符串
    
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize: 12] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + 115;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSHistoryCell*cell = [tableView dequeueReusableCellWithIdentifier:@"PSHistoryCell"];
    PSLocalMeetingHistoryViewModel *meetingHistoryModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    PSMeettingHistory *MeettingHistory= meetingHistoryModel.meeetHistorys[indexPath.row];
    cell.iconLable.text=[NSString stringWithFormat:@"%@",MeettingHistory.name];
    cell.otherLabel.lineBreakMode=NSLineBreakByWordWrapping;
    cell.otherLabel.numberOfLines=0;
    NSString*status=MeettingHistory.status;
    
    
    NSString*meet_PENDING=NSLocalizedString(@"meet_PENDING", nil);
    NSString*meet_PASSED=NSLocalizedString(@"meet_PASSED", nil);
    NSString*meet_FINISHED=NSLocalizedString(@"meet_FINISHED", nil);
    NSString*meet_EXPIRED=NSLocalizedString(@"meet_EXPIRED", nil);
    NSString*meet_DENIED=NSLocalizedString(@"meet_DENIED_HISTORY", nil);
    NSString*meet_CACELED=NSLocalizedString(@"meet_CACELED", nil);
    NSString*apply_data=NSLocalizedString(@"apply_data", @"申请日期");
    NSString*meet_data=NSLocalizedString(@"meet_data", @"会见日期");
    NSString*Refuse_reason=NSLocalizedString(@"Refuse_reason", @"拒绝原因");
    if ([status isEqualToString:@"PENDING"]) {
        cell.otherTextLabel.text=@"";
        cell.otherLabel.text=@"";
        [cell.statusButton setBackgroundColor:UIColorFromRGB(255, 138, 7)];
        [cell.statusButton setTitle:meet_PENDING forState:UIControlStateNormal];
        
        cell.dateTextLabel.text=apply_data;
        cell.dateLabel.text=MeettingHistory.applicationDate;
        if ([MeettingHistory.canCancel isEqualToString:@"1"]) {
            cell.cancleButton.hidden=NO;
        }else{
            cell.cancleButton.hidden=YES;
        }
        // cell.cancleButton.hidden=NO;
        cell.cancleButton.tag=indexPath.row;
        [cell.cancleButton addTarget:self action:@selector(cancelApplyMeeting:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([status isEqualToString:@"PASSED"]){
        cell.otherTextLabel.text=meet_data;
        cell.otherLabel.text=MeettingHistory.meetingTime;
        [cell.statusButton setBackgroundColor:UIColorFromRGB(0, 142, 60)];
        [cell.statusButton setTitle:meet_PASSED forState:UIControlStateNormal];
        cell.dateTextLabel.text=apply_data;
        cell.dateLabel.text=MeettingHistory.applicationDate;
        if ([MeettingHistory.canCancel isEqualToString:@"1"]) {
            cell.cancleButton.hidden=NO;
        }else{
            cell.cancleButton.hidden=YES;
        }
        
        cell.cancleButton.tag=indexPath.row;
        [cell.cancleButton addTarget:self action:@selector(cancelApplyMeeting:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([status isEqualToString:@"FINISHED"]){
        cell.otherTextLabel.text=meet_data;
        cell.otherLabel.text=MeettingHistory.meetingTime;
        [cell.statusButton setBackgroundColor:UIColorFromRGB(83, 119, 185)];
        [cell.statusButton setTitle:meet_FINISHED forState:UIControlStateNormal];
        cell.dateTextLabel.text=apply_data;
        cell.dateLabel.text=MeettingHistory.applicationDate;
        cell.cancleButton.hidden=YES;
    }
    else if ([status isEqualToString:@"DENIED"]){
        
        if ([MeettingHistory.remarks isEqualToString:@"null"]) {
            cell.otherTextLabel.text=Refuse_reason;
            cell.otherLabel.text=@"";
        }else{
            cell.otherTextLabel.text=Refuse_reason;
            cell.otherLabel.text=MeettingHistory.remarks;
        }
        [cell.statusButton setBackgroundColor:UIColorFromRGB(192, 3, 3)];
        [cell.statusButton setTitle:meet_DENIED forState:UIControlStateNormal];
        cell.dateTextLabel.text=apply_data;
        cell.dateLabel.text=MeettingHistory.applicationDate;
        cell.cancleButton.hidden=YES;
    }
    else if ([status isEqualToString:@"CANCELED"]){
        
        if ([MeettingHistory.remarks isEqualToString:@"null"]) {
            cell.otherTextLabel.text=Refuse_reason;
            cell.otherLabel.text=@"";
        }else{
            cell.otherTextLabel.text=Refuse_reason;
            cell.otherLabel.text=MeettingHistory.remarks;
        }
        [cell.statusButton setBackgroundColor:UIColorFromRGB(192, 3, 3)];
        [cell.statusButton setTitle:meet_CACELED forState:UIControlStateNormal];
        cell.dateTextLabel.text=apply_data;
        cell.dateLabel.text=MeettingHistory.applicationDate;
        cell.cancleButton.hidden=YES;
    }
    else if ([status isEqualToString:@"EXPIRED"]){
        
        cell.otherTextLabel.text=meet_data;
        cell.otherLabel.text=MeettingHistory.meetingTime;
        [cell.statusButton setBackgroundColor:UIColorFromRGB(153, 153, 153)];
        [cell.statusButton setTitle:meet_EXPIRED forState:UIControlStateNormal];
        cell.dateTextLabel.text=apply_data;
        cell.dateLabel.text=MeettingHistory.applicationDate;
        cell.cancleButton.hidden=YES;
    }
    return cell;
}



#pragma mark - DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    PSLocalMeetingHistoryViewModel *historyViewModel = (PSLocalMeetingHistoryViewModel *)self.viewModel;
    UIImage *emptyImage = historyViewModel.dataStatus == PSDataEmpty ? [UIImage imageNamed:@"universalNoneIcon"] : [UIImage imageNamed:@"universalNetErrorIcon"];
    return historyViewModel.dataStatus == PSDataInitial ? nil : emptyImage;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    PSLocalMeetingHistoryViewModel *historyViewModel = (PSLocalMeetingHistoryViewModel *)self.viewModel;
    NSString *tips = historyViewModel.dataStatus == PSDataEmpty ? EMPTY_CONTENT : NET_ERROR;
    return historyViewModel.dataStatus == PSDataInitial ? nil : [[NSAttributedString alloc] initWithString:tips attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}];
    
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    PSLocalMeetingHistoryViewModel *historyViewModel = (PSLocalMeetingHistoryViewModel *)self.viewModel;
    return historyViewModel.dataStatus == PSDataError ? [[NSAttributedString alloc] initWithString:CLICK_ADD attributes:@{NSFontAttributeName:AppBaseTextFont1,NSForegroundColorAttributeName:AppBaseTextColor1}] : nil;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self refreshData];
}



- (void)cancelApplyMeeting:(UIButton*)sender {
    PSLocalMeetingHistoryViewModel *meetingHistoryViewModel =(PSLocalMeetingHistoryViewModel *)self.viewModel;
    PSMeettingHistory *MeettingHistory= meetingHistoryViewModel.meeetHistorys[sender.tag];
    meetingHistoryViewModel.cancelId=MeettingHistory.historyId;
    PSCancelReasonView *cancelReasonView = [PSCancelReasonView new];
    [cancelReasonView setDidCancel:^(NSString *reason) {
        meetingHistoryViewModel.cause=reason;
    }];
    [cancelReasonView show];
    cancelReasonView.clickIndex = ^(NSInteger index) {
        if (index==2) {
            NSLog(@"%@ || %@",meetingHistoryViewModel.cancelId,meetingHistoryViewModel.cause);
            [meetingHistoryViewModel MeetapplyCancelCompleted:^(PSResponse *response) {
                [self refreshData];
                NSString*cancel_apply=NSLocalizedString(@"cancel_success", @"取消会见成功");
                [PSTipsView showTips:cancel_apply];
                //埋点...
                [SDTrackTool logEvent:CANCEL_FAMILY_CALL];
                
            } failed:^(NSError *error) {
                [self showNetError:error];
            }];
        }
    };
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
