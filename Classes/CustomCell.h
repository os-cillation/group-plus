//
//  CustomCell.h
//  FotoFTP
//
//  Created by Benjamin Mies on 12.04.10.
//  Copyright 2010 2010 os-cillation e.K.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell {
	UILabel *primaryLabel;
	UILabel *secondaryLabel;
	UIImageView *myImageView;
}

@property(nonatomic,retain)UILabel *primaryLabel;
@property(nonatomic,retain)UILabel *secondaryLabel;
@property(nonatomic,retain)UIImageView *myImageView;

@end
