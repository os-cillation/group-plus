//
//  CustomCell.m
//  FotoFTP
//
//  Created by Benjamin Mies on 12.04.10.
//  Copyright 2010 2010 os-cillation e.K.. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

@synthesize primaryLabel,secondaryLabel,myImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.textAlignment = UITextAlignmentLeft;
		primaryLabel.font = [UIFont systemFontOfSize:16];
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.textAlignment = UITextAlignmentLeft;
		secondaryLabel.font = [UIFont systemFontOfSize:12];
		myImageView = [[UIImageView alloc]init];
		[self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:myImageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.textAlignment = UITextAlignmentLeft;
		primaryLabel.font = [UIFont systemFontOfSize:16];
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.textAlignment = UITextAlignmentLeft;
		secondaryLabel.font = [UIFont systemFontOfSize:12];
		myImageView = [[UIImageView alloc]init];
		[self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:myImageView];
		
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	
	frame= CGRectMake(boundsX+10 ,5, 50, 50);
	myImageView.frame = frame;
	
	frame= CGRectMake(boundsX+70 ,5, 210, 50);
	primaryLabel.frame = frame;
	
	/*frame= CGRectMake(boundsX+70 ,30, 220, 15);
	secondaryLabel.frame = frame;*/
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
