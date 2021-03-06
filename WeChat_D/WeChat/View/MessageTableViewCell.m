//
//  MessageTableViewCell.m
//  WeChat_D
//
//  Created by tztddong on 16/7/18.
//  Copyright © 2016年 dongjiangpeng. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageModel.h"

#define ImageDefaultSizeWH 150.0
@interface MessageTableViewCell ()
/**
 *  头像
 */
@property(nonatomic,strong)UIImageView *headerView;
/**
 *  底层图片
 */
@property(nonatomic,strong)UIImageView *backImgaeView;
/**
 *  文字消息
 */
@property(nonatomic,strong)UILabel *messageText;
/**
 *  图片消息
 */
@property(nonatomic,strong)UIImageView *messsgeImage;
/**
 *  语音消息
 */
@property(nonatomic,strong)UIImageView *messageVoice;
/**
 *  语音时间
 */
@property(nonatomic,strong)UILabel *timeLabel;
/** 语音未读标记 */
@property(nonatomic,strong) UIView *voiceUnread;
/** 时间 */
@property(nonatomic,strong) NSTimer *timer;
/** 记录时间 */
@property(nonatomic,assign) NSInteger timerCount;
/**
 *  发送失败显示
 */
@property(nonatomic,strong)UIButton *sendFiledBtn;
@end

@implementation MessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self congifViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordPlayFinish) name:RECORDPLAYFINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordPlayBegin) name:RECORDPLAYBEGIN object:nil];
    }
    return self;
}

- (void)congifViews{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.backImgaeView];
    
    self.contentView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.contentView addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 1.f;
    [self.contentView addGestureRecognizer:longPress];
}

#pragma mark 点击消息 / 头像 /空白 处的事件 代理
- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.backImgaeView.frame, tapPoint)) {
            if ([self.delegate respondsToSelector:@selector(messageCellTappedMessage:MessageModel:)]) {
                [self.delegate messageCellTappedMessage:self MessageModel:self.model];
                switch (self.model.messageType) {
                    case MessageType_Voice:
                    {
                        [self.timer setFireDate:[NSDate distantPast]];
                        self.contentView.userInteractionEnabled = NO;
                        NSFileManager *fileManger = [NSFileManager defaultManager];
                        if ([fileManger fileExistsAtPath:self.model.voiceLocaPath]){
                            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:self.model.voiceLocaPath];
                        }else{
                            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:self.model.voicePath];
                        }
                        
                        self.voiceUnread.hidden = YES;

                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }else if (CGRectContainsPoint(self.headerView.frame, tapPoint)) {
            if ([self.delegate respondsToSelector:@selector(messageCellTappedHead:)]) {
                [self.delegate messageCellTappedHead:self];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(messageCellTappedBlank:)]) {
                [self.delegate messageCellTappedBlank:self];
            }
        }
    }
}

#pragma mark 长按消息
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPtess{
    
    CGPoint tapPoint = [longPtess locationInView:self.contentView];
    if (CGRectContainsPoint(self.backImgaeView.frame, tapPoint)) {
        if ([self.delegate respondsToSelector:@selector(messageCellLonrPressMessage:MessageModel:indexPath:)]) {
            [self.delegate messageCellLonrPressMessage:self MessageModel:self.model indexPath:self.indexPath];
        }
    }
}
#pragma mark 懒加载views
- (UIImageView *)headerView{
    
    if (!_headerView) {
        _headerView = [[UIImageView alloc]init];
    }
    return _headerView;
}

- (UIImageView *)backImgaeView{
    
    if (!_backImgaeView) {
        _backImgaeView = [[UIImageView alloc]init];
    }
    return _backImgaeView;
}

- (UILabel *)messageText{
    
    if (!_messageText) {
        _messageText = [[UILabel alloc]init];
        _messageText.numberOfLines = 0;
        _messageText.font = FONTSIZE(15);
    }
    return _messageText;
}

- (UIImageView *)messsgeImage{
    
    if (!_messsgeImage) {
        _messsgeImage = [[UIImageView alloc]init];
        _messsgeImage.backgroundColor = [UIColor clearColor];
    }
    return _messsgeImage;
}

- (UIImageView *)messageVoice{
    
    if (!_messageVoice) {
        _messageVoice = [[UIImageView alloc]init];
    }
    return _messageVoice;
}

- (UILabel *)timeLabel{
    
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.hidden = YES;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = FONTSIZE(14);
    }
    return _timeLabel;
}

- (UIView *)voiceUnread{
    
    if (!_voiceUnread) {
        
        _voiceUnread = [[UIView alloc]init];
        _voiceUnread.backgroundColor = [UIColor redColor];
        _voiceUnread.layer.cornerRadius = KMARGIN/2;
        _voiceUnread.layer.masksToBounds = YES;
    }
    return _voiceUnread;
}

- (UIButton *)sendFiledBtn{
    
    if (!_sendFiledBtn) {
        _sendFiledBtn = [[UIButton alloc]init];
        _sendFiledBtn.backgroundColor = [UIColor clearColor];
        [_sendFiledBtn setImage:[UIImage imageNamed:@"MessageSendFail_28x28_"] forState:UIControlStateNormal];
        [_sendFiledBtn addTarget:self action:@selector(reSendMessage) forControlEvents:UIControlEventTouchUpInside];
        [_sendFiledBtn.titleLabel setFont:FONTSIZE(11)];
        
    }
    return _sendFiledBtn;
}

#pragma mark 播放语音的动画
- (NSTimer *)timer{
    
    if (!_timer) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateSliderValue) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (void)updateSliderValue{
    
    self.timerCount ++;
    NSLog(@"%zd",self.timerCount);
    if (self.model.isMineMessage) {
        self.messageVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"message_voice_sender_playing_%zd",self.timerCount%3+1]];
    }else{
        self.messageVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"message_voice_receiver_playing_%zd",self.timerCount%3+1]];
    }
}


#pragma mark 赋值
- (void)setModel:(MessageModel *)model{
    
    _model = model;
    
    //判断是自发还是朋友发
    if (model.isMineMessage) {
        
        [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-KMARGIN);
            make.top.offset(KMARGIN);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        self.headerView.image = [UIImage imageNamed:@"fts_default_headimage_36x36_"];
        self.headerView.backgroundColor = [UIColor whiteColor];
        //判断消息类型
        switch (model.messageType) {
            case MessageType_Text:{
                //文字消息
                self.timeLabel.hidden = YES;
                [self.backImgaeView addSubview:self.messageText];
                //换行设置
                self.messageText.attributedText = [PublicMethod emojiWithText:model.messagetext];
                self.messageText.preferredMaxLayoutWidth = KWIDTH/5*3;
                [self.messageText mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.backImgaeView).insets(UIEdgeInsetsMake(KMARGIN, 3.0/2*KMARGIN, KMARGIN, 3.0/2*KMARGIN));
                }];
                [self.backImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_top);
                    make.right.equalTo(self.headerView.mas_left).with.offset(-KMARGIN/2);
                    make.left.equalTo(self.messageText.mas_left).with.offset(-3.0/2*KMARGIN);
                    make.bottom.equalTo(self.messageText.mas_bottom).with.offset(KMARGIN);
                }];
                
            }

                break;
            case MessageType_Voice:{
                //语音消息
                [self.contentView addSubview:self.timeLabel];
                [self.backImgaeView addSubview:self.messageVoice];
                [self.backImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_top);
                    make.right.equalTo(self.headerView.mas_left).with.offset(-KMARGIN/2);
                    if (model.voiceTime < 5) {
                        make.width.equalTo(@80);
                    }else if(model.voiceTime*2.0*KMARGIN > KWIDTH/5*3.0){
                        make.width.equalTo(@(KWIDTH/5*3.0));
                    }else{
                        make.width.equalTo(@(model.voiceTime*2*KMARGIN));
                    }
                    make.bottom.equalTo(self.headerView.mas_bottom);
                }];
                self.messageVoice.image = [UIImage imageNamed:@"message_voice_sender_playing_3"];
                [self.messageVoice mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.backImgaeView.mas_centerY);
                    make.right.offset(-KMARGIN);
                    make.size.mas_equalTo(CGSizeMake(20, 20));
                }];
                self.timeLabel.hidden = NO;
                self.timeLabel.text = [NSString stringWithFormat:@"%d s",model.voiceTime];
                [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.backImgaeView.mas_centerY);
                    make.right.equalTo(self.backImgaeView.mas_left).with.offset(-KMARGIN/2);
                }];
            }
                
                break;
            case MessageType_Picture:{
                //图片消息
                self.timeLabel.hidden = YES;
                [self.backImgaeView addSubview:self.messsgeImage];
                NSFileManager *fileManger = [NSFileManager defaultManager];
#warning 因为发送方发送消息的时候 环信没有返回网络路径 而重新进入聊天界面后确是从网络加载的图片 好坑 所以我们要先判断 是否存在本地图片 也就是发送时我们自己存下的那个本地路径 若有就加载 没有再去网络加载
                if ([fileManger fileExistsAtPath:model.image_mark]) {
                    self.messsgeImage.image = [UIImage imageWithContentsOfFile:model.image_mark];;
                }else{
                    [self.messsgeImage sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"location"]];
                }
#warning 关于图片的size问题 坑了好久 本地的size可以直接拿到 没问题 但是从网络下载的size 由于SDWebImage是异步下载 我们无法再当前主线程直接拿到size 若直接用[self.messsgeImage.image.size] 赋值的话size一直是(60 ,60) 所以无法正常显示图片 然后想到使用SD的下载方法中有一个下载完成的回调 所以想着在回调中直接拿到image的size 虽然拿到了 但是无法进行赋值 因为我们在进行布局和计算cell高度的时候 image还在异步下载呢 到时size一直是zero 最后我将计算size的方法放到model中 这样便解决了size的问题
                
                CGSize imageSize = model.thumbnailSize;
                if (imageSize.width == 0) {
                    imageSize = CGSizeMake(150, 150);
                }
                [self.messsgeImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.backImgaeView).insets(UIEdgeInsetsMake(KMARGIN, 3.0/2*KMARGIN, KMARGIN, 3.0/2*KMARGIN));
                    if (imageSize.width > ImageDefaultSizeWH) {
                        make.size.mas_equalTo(CGSizeMake(ImageDefaultSizeWH, ImageDefaultSizeWH/imageSize.width * imageSize.height));
                    }else{
                        make.size.mas_equalTo(imageSize);
                    }

                }];
                [self.backImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_top);
                    make.right.equalTo(self.headerView.mas_left).with.offset(-KMARGIN/2);
                    make.left.equalTo(self.messsgeImage.mas_left).with.offset(-3.0/2*KMARGIN);
                    make.bottom.equalTo(self.messsgeImage.mas_bottom).with.offset(KMARGIN);
                }];
        }
                break;
                
            default:
                break;
        }
        self.backImgaeView.image = [self backImage:[UIImage imageNamed:@"message_sender_background_normal"]];
        self.sendFiledBtn.hidden = model.sendSuccess == EMMessageStatusSuccessed ? YES:NO;
        [self.contentView addSubview:self.sendFiledBtn];
        [self.sendFiledBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backImgaeView.mas_centerY);
            make.right.equalTo(self.backImgaeView.mas_left).with.offset(-KMARGIN/2);
        }];
        
    }else{//判断是朋友发
        [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(KMARGIN);
            make.top.offset(KMARGIN);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        self.headerView.image = [UIImage imageNamed:@"fts_default_headimage_36x36_"];
        self.headerView.backgroundColor = [UIColor redColor];
        switch (model.messageType) {
            case MessageType_Text:{
                
                self.timeLabel.hidden = YES;
                [self.backImgaeView addSubview:self.messageText];
                //换行设置
                self.messageText.attributedText = [PublicMethod emojiWithText:model.messagetext];
                self.messageText.preferredMaxLayoutWidth = KWIDTH/5*3;
                [self.messageText mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.backImgaeView).insets(UIEdgeInsetsMake(KMARGIN, 3.0/2*KMARGIN, KMARGIN, 3.0/2*KMARGIN));
                }];
                [self.backImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_top);
                    make.left.equalTo(self.headerView.mas_right).with.offset(KMARGIN/2);
                    make.right.equalTo(self.messageText.mas_right).with.offset(3.0/2*KMARGIN);
                    make.bottom.equalTo(self.messageText.mas_bottom).with.offset(KMARGIN);
                }];
            }
                break;
            case MessageType_Voice:{
                
                [self.contentView addSubview:self.timeLabel];
                [self.backImgaeView addSubview:self.messageVoice];
                [self.backImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_top);
                    make.left.equalTo(self.headerView.mas_right).with.offset(KMARGIN/2);
                    if (model.voiceTime < 5) {
                        make.width.equalTo(@80);
                    }else if(model.voiceTime*2.0*KMARGIN > KWIDTH/5*3.0){
                        make.width.equalTo(@(KWIDTH/5*3.0));
                    }else{
                        make.width.equalTo(@(model.voiceTime*2*KMARGIN));
                    }
                    make.bottom.equalTo(self.headerView.mas_bottom);
                }];
                self.messageVoice.image = [UIImage imageNamed:@"message_voice_receiver_playing_3"];
                [self.messageVoice mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.backImgaeView.mas_centerY);
                    make.left.offset(KMARGIN);
                    make.size.mas_equalTo(CGSizeMake(20, 20));
                }];
                self.timeLabel.hidden = NO;
                self.timeLabel.text = [NSString stringWithFormat:@"%d s",model.voiceTime];
                [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.backImgaeView.mas_centerY);
                    make.left.equalTo(self.backImgaeView.mas_right).with.offset(KMARGIN/2);
                }];
                [self.backImgaeView addSubview:self.voiceUnread];
                self.voiceUnread.hidden = model.voiceIsListen;
                [self.voiceUnread mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.backImgaeView.mas_top).with.offset(0);
                    make.left.equalTo(self.backImgaeView.mas_right).with.offset(-KMARGIN);
                    make.size.mas_equalTo(CGSizeMake(KMARGIN, KMARGIN));
                }];
            }
                
                break;
            case MessageType_Picture:{
                
                self.timeLabel.hidden = YES;
                NSFileManager *fileManger = [NSFileManager defaultManager];
                if ([fileManger fileExistsAtPath:model.image_mark]) {
                    self.messsgeImage.image = [UIImage imageWithContentsOfFile:model.image_mark];;
                }else{
                    [self.messsgeImage sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"location"]];
                }
                CGSize imageSize = model.thumbnailSize;
                if (imageSize.width == 0) {
                    imageSize = CGSizeMake(150, 150);
                }

                NSLog(@"%f",imageSize.width);
                [self.backImgaeView addSubview:self.messsgeImage];
                [self.messsgeImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.backImgaeView).insets(UIEdgeInsetsMake(KMARGIN, 3.0/2*KMARGIN, KMARGIN, 3.0/2*KMARGIN));
                    make.size.mas_equalTo(CGSizeMake(ImageDefaultSizeWH, ImageDefaultSizeWH/imageSize.width * imageSize.height));
                }];
                [self.backImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_top);
                    make.left.equalTo(self.headerView.mas_right).with.offset(KMARGIN/2);
                    make.right.equalTo(self.messsgeImage.mas_right).with.offset(3.0/2*KMARGIN);
                    make.bottom.equalTo(self.messsgeImage.mas_bottom).with.offset(KMARGIN);
                }];
            }
                break;
                
            default:
                break;
        }
        
        self.backImgaeView.image = [self backImage:[UIImage imageNamed:@"message_receiver_background_normal"]];
        self.sendFiledBtn.hidden = model.sendSuccess == EMMessageStatusSuccessed ? YES:NO;
        [self.contentView addSubview:self.sendFiledBtn];
        [self.sendFiledBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backImgaeView.mas_centerY);
            make.left.equalTo(self.backImgaeView.mas_right).with.offset(KMARGIN/2);
        }];
    }
}

+ (CGFloat)cellHeightWithModel:(MessageModel *)model{
    
    MessageTableViewCell *cell = [[MessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageTableViewCell"];
    [cell setModel:model];
    [cell layoutIfNeeded];
    
    CGFloat height_1  = CGRectGetMaxY(cell.backImgaeView.frame);
    CGFloat height_2 = CGRectGetMaxY(cell.headerView.frame);
    return MAX(height_1, height_2)+KMARGIN/2;
}

- (UIImage *)backImage:(UIImage *)image{

    // 设置端盖的值
    CGFloat top = image.size.height * 0.6;
    CGFloat left = image.size.width * 0.5;
    CGFloat bottom = image.size.height * 0.3;
    CGFloat right = image.size.width * 0.5;
    // 设置端盖的值
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    // 设置拉伸的模式
    UIImageResizingMode mode = UIImageResizingModeStretch;
    // 拉伸图片
    UIImage *newImage = [image resizableImageWithCapInsets:edgeInsets resizingMode:mode];
    
    return newImage;
}

//语音开始播放
- (void)recordPlayBegin{
    
}
//语音播放完毕
- (void)recordPlayFinish{
    
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timerCount = 0;
    self.contentView.userInteractionEnabled = YES;
    if (self.model.isMineMessage) {
        [self.messageVoice setImage:[UIImage imageNamed:@"message_voice_sender_normal"]];
    }else{
        [self.messageVoice setImage:[UIImage imageNamed:@"message_voice_receiver_normal"]];
    }
}


#pragma mark 重新发送
- (void)reSendMessage{
    
    if ([self.delegate respondsToSelector:@selector(resendMessageWith:indexPath:)]) {
        [self.delegate resendMessageWith:self indexPath:self.indexPath];
    }
}
//当离开聊天界面时
- (void)viewBack{
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timerCount = 0;
    self.contentView.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECORDPLAYBEGIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECORDPLAYFINISH object:nil];
}

//重用时调用
- (void)prepareForReuse{
    
    if (self.backImgaeView.subviews.count) {
        for (UIView *view in self.backImgaeView.subviews) {
            [view removeFromSuperview];
        }
    }
    if (self.timeLabel) {
        [self.timeLabel removeFromSuperview];
        self.timeLabel = nil;
    }
}

@end
