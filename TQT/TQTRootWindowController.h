//
//  TQTRootWindowController.h
//  TQT
//
//  Created by lishunnian on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TQTRootWindowController : NSWindowController {
@private
    IBOutlet NSImageView *userImgView_;
    IBOutlet NSView* tableView_;
}

@property (assign, readonly) NSImageView *userImgView;
@property (assign, readonly) NSView *tableView;
@end
