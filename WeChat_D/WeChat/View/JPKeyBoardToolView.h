//
//  JPKeyBoardToolView.h
//  WeChat_D
//
//  Created by tztddong on 16/7/12.
//  Copyright © 2016年 dongjiangpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ButtonType_None,//不显示
    ButtonType_Record,//显示录音
    ButtonType_RecordLong,
    ButtonType_Face,//显示表情
    ButtonType_AddMore,//显示更多
    ButtonType_KeyBoard,//显示键盘
} ButtonType;

@class JPKeyBoardToolView;
@protocol JPKeyBoardToolViewDelegate <NSObject>

- (void)keyBoardToolViewFrameDidChange:(JPKeyBoardToolView *)toolView frame:(CGRect)frame;

@end

@interface JPKeyBoardToolView : UIView

@property(nonatomic,assign) CGFloat superViewHeight;
@property(nonatomic,weak)id<JPKeyBoardToolViewDelegate> delegate;

@end