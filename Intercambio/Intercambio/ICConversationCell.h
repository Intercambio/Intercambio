//
//  ICConversationCell.h
//  Intercambio
//
//  Created by Tobias Kräntzer on 06.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <IntercambioCore/IntercambioCore.h>
#import <UIKit/UIKit.h>

@interface ICConversationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (nonatomic, strong) id<ICConversationViewModel> cellModel;

@end
