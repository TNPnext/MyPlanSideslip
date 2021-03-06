//
//  SideMenuViewController.m
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "RESideMenu.h"
#import "DataCenter.h"
#import "WZLBadgeImport.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "PhotoViewController.h"
#import "MessagesViewController.h"
#import "SideMenuViewController.h"
#import "SettingsPersonalViewController.h"
#import "PersonalCenterNewViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface SideMenuViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *menuImgArray;
@property (strong, nonatomic) NSMutableArray *menuArray;

@end

@implementation SideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = color_GrayDark;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [NotificationCenter addObserver:self selector:@selector(reload) name:NTFLogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(reload) name:NTFLogOut object:nil];
    [NotificationCenter addObserver:self selector:@selector(reload) name:NTFSettingsSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(reload) name:NTFMessagesSave object:nil];
    
    [self setMenuArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setMenuArray
{
    self.menuImgArray = [NSMutableArray arrayWithObjects:png_Icon_Menu_PersonalCenter, png_Icon_Menu_PhotoLine, png_Icon_Menu_Help, png_Icon_Menu_FiveStar, png_Icon_Menu_Messages, png_Icon_Menu_About, nil];
    self.menuArray = [NSMutableArray arrayWithObjects:STRViewTitle4, STRViewTitle5, STRViewTitle6, STRViewTitle7, STRViewTitle12, STRViewTitle9, nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [UIView new];
    UIColor *bgColor = [UIColor colorWithPatternImage: [UIImage imageNamed:png_Bg_SideTop]];
    headerView.backgroundColor = bgColor;
    
    UIImageView *avatar = [UIImageView new];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    [avatar setCornerRadius:30];
    avatar.userInteractionEnabled = YES;
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:avatar];
    UIImage *image = [UIImage imageNamed:png_AvatarDefault1];
    if ([Config shareInstance].settings.avatar)
    {
        image = [UIImage imageWithData:[Config shareInstance].settings.avatar];
    }
    avatar.image = image;

    NSString *nickname = STRCommonTip12;
    if ([Config shareInstance].settings.nickname)
    {
        nickname = [Config shareInstance].settings.nickname;
    }
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = nickname;
    nameLabel.font = font_Bold_20;
    nameLabel.textColor = [Utils getGenderColor];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:nameLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(avatar, nameLabel);
    NSDictionary *metrics = @{@"x": @([UIScreen mainScreen].bounds.size.width / 4 - 15)};
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar(60)]-10-[nameLabel]-15-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-x-[avatar(60)]" options:0 metrics:metrics views:views]];
    
    avatar.userInteractionEnabled = YES;
    nameLabel.userInteractionEnabled = YES;
    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    [nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor clearColor];
    if (self.menuArray.count == 0)
    {
        return cell;
    }
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [Utils getGenderColor];
    [cell setSelectedBackgroundView:selectedBackground];
    cell.imageView.image = [UIImage imageNamed:self.menuImgArray[indexPath.row]];
    cell.textLabel.text = self.menuArray[indexPath.row];
    cell.textLabel.font = font_Normal_16;
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == 4 && [PlanCache hasUnreadMessages])
    {
        [cell.imageView showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
        cell.imageView.badgeCenterOffset = CGPointMake(20, 0);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 0:
        {//个人中心
            PersonalCenterNewViewController *controller = [[PersonalCenterNewViewController alloc] init];
            [self setContentViewController:controller];
            break;
        }
        case 1:
        {//岁月影像
            PhotoViewController *controller = [[PhotoViewController alloc] init];
            [self setContentViewController:controller];
            break;
        }
        case 2:
        {//常见问题
            HelpViewController *controller = [[HelpViewController alloc] init];
            [self setContentViewController:controller];
            break;
        }
        case 3:
        {//五星鼓励
            //到下载界面
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id983206049?mt=8"]];
            //到评论界面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=983206049&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
//        case 4: {//打赏作者
//            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
//            if (!mailClass) {
//                [self alertButtonMessage:str_More_Feedback_Tips1];
//                return;
//            }
//            if (![mailClass canSendMail]) {
//                [self alertButtonMessage:str_More_Feedback_Tips2];
//                return;
//            }
//            [self displayMailPicker];
//            break;
//        }
        case 4:
        {//系统消息
            MessagesViewController *controller = [[MessagesViewController alloc]init];
            [self setContentViewController:controller];
            break;
        }
        case 5:
        {//关于我们
            AboutViewController *controller = [[AboutViewController alloc]init];
            [self setContentViewController:controller];
        }
        default: break;
    }
}

- (void)setContentViewController:(UIViewController *)viewController
{
    viewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *navController = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
    [navController pushViewController:viewController animated:NO];
    
    [self.sideMenuViewController hideMenuViewController];
}

- (void)pushLoginPage
{
    if ([LogIn isLogin])
    {
        UINavigationController *navController = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
        SettingsPersonalViewController *controller = [[SettingsPersonalViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [navController pushViewController:controller animated:YES];
    }
    
    [self.sideMenuViewController hideMenuViewController];
}

- (void)reload
{
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    NSString *device = [NSString stringWithFormat:@"（%@，iOS%@）", [Utils getDeviceType], [Utils getiOSVersion]];
    NSString *subject = [NSString stringWithFormat:@"%@ V%@%@", STRViewTips69, [Utils getAppVersion], device];
    [mailPicker setSubject:subject];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject:STRFeedbackEmail];
    [mailPicker setToRecipients: toRecipients];
    
    [mailPicker setMessageBody:STRViewTips64 isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = STRViewTips65;
            break;
        case MFMailComposeResultSaved:
            [self alertToastMessage:STRViewTips66];
            break;
        case MFMailComposeResultSent:
            [self alertToastMessage:STRViewTips67];
            break;
        case MFMailComposeResultFailed:
            [self alertButtonMessage:STRViewTips68];
            break;
        default:
            msg = @"";
            break;
    }
}

@end
