//
//  SHProfileViewController.m
//  Happiness
//
//  Created by Cheney on 16/3/16.
//  Copyright © 2016年 Cheney. All rights reserved.
//

#import "SHProfileViewController.h"
#import "SHAboutusViewController.h"
#import "SHMyViewController.h"
#import "XJJAccountTool.h"
#import <UIImageView+WebCache.h>
#import "XJJImageTool.h"
#import "SHMyProfileTableViewCell.h"
#import "UIWindow+XJJSwitchRVC.h"

@interface SHProfileViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)NSArray *arr;

@end

@implementation SHProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableview];
    
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableview registerClass:[SHMyProfileTableViewCell class] forCellReuseIdentifier:@"cell1"];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.bounces=NO;
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleSingleLine;//分割线
    self.arr=@[@"清理缓存",@"意见反馈",@"关于小幸福"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //分组数 也就是section数
    return 3;
}

//设置每个分组下tableview的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==1) {
        return self.arr.count;
    }
    return 1;
}
//每个分组上边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 10;
    }else if (section==1) {
        return 15;
    }else{
        return 30;
    }
}

//每一个分组下对应的tableview 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }
    return 40;
}

//设置每行对应的cell（展示的内容）
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //取出本地账户信息
    XJJAccount *account = [XJJAccountTool account];
    XJJImageModel *imageModel = [XJJImageTool imageModel];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (indexPath.section==0) {
        SHMyProfileTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        //后续加入判断男女,加载不同的默认头像
        if (imageModel.iconImage) {
            myCell.iconImage.image = imageModel.iconImage;
        }else{
            [myCell.iconImage sd_setImageWithURL:[NSURL URLWithString:account.iconURL] placeholderImage:[UIImage imageNamed:@"menses-gender-man"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error) {
                    imageModel.iconImage = image;
                    [XJJImageTool saveImageModel:imageModel];
                }
            }];
        }
        
        if (account.nickName) {
            myCell.nickNameLabel.text = account.nickName;
        }else{
            myCell.nickNameLabel.text= @"请设置昵称";
        }

        myCell.loveNumLabel.text = [NSString stringWithFormat:@"幸福号:%@",account.userName];
        return myCell;
    }else if (indexPath.section==1) {
        cell.textLabel.text=[self.arr objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment=NSTextAlignmentLeft;
    }else{
        cell.textLabel.text=@"退出登陆";
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击cell  松开后颜色恢复点击前的颜色
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        SHMyProfileTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        SHMyViewController *my = [SHMyViewController new];
        my.nickName = cell.nickNameLabel.text;
        my.iconImage = cell.iconImage.image;
        [self.navigationController pushViewController:my animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0){
        //弹出框
        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定清除缓存?" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"是" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            [self setDelete];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"否" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alerVC addAction:action1];
        [alerVC addAction:action2];
        [self presentViewController:alerVC animated:YES completion:nil];
    } else if (indexPath.section == 1 && indexPath.row == 1){
        //反馈(默认页面)
        

    } else if (indexPath.section == 1 && indexPath.row == 2){
        SHAboutusViewController *aboutus = [SHAboutusViewController new];
        [self.navigationController pushViewController:aboutus animated:YES];
    }
    
    if (indexPath.section == 3) {
        [XJJAccountTool removeAccount];
        [XJJImageTool removeImageModel];
        [UIApplication sharedApplication].keyWindow.rootViewController = nil;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window switchRootViewController];
    }
}

//清除缓存方法
-(void)setDelete{
    [self clearCache];
}



#pragma mark -- 缓存功能
/**
 * 垃圾清理功能
 */
-(void)clearCache
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    unsigned long long size = [self fileSizeAtPath:cachePath];
    NSString *contents = [NSString stringWithFormat:@"%@%.2fM,%@",@"当前有缓存",size/1024.0,@"清除有助于减少空间占有，但会导致加载之前浏览过的图片变慢，确定要清除？"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:contents delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
    //NSLog(NSString * _Nonnull format, ...)
}


#pragma mark-UIAlertViewDelegate
/**
 * alert结束后调用
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_HUD];
        _HUD.center = self.view.center;
        _HUD.minSize = CGSizeMake(135.0f, 135.0f);
        _HUD.mode = MBProgressHUDModeIndeterminate;
        _HUD.labelText = @"清除中。。。";
        [_HUD showWhileExecuting:@selector(clear) onTarget:self withObject:nil animated:YES];
    }
}
- (void)clear
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    for (NSString *p in files) {
        NSError *error;
        NSString *path = [cachePath stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
        }
    }
    [self clearCacheSuccess];
}
/**
 * 清理缓存成功
 */
-(void)clearCacheSuccess{
    sleep(2);
    _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_tips_ok.png"]];
    _HUD.mode = MBProgressHUDModeCustomView;
    _HUD.labelText = @"清除成功";
    sleep(1);
}
/**
 * 计算缓存大小
 */
-(long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil]fileSize];
    }
    return 0;
}

@end
