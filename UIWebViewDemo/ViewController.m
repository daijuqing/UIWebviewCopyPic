//
//  ViewController.m
//  UIWebViewDemo
//
//  Created by kezhiyou on 17/3/2.
//  Copyright © 2017年 daijuqing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIGestureRecognizerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *MyWebView;


@end


@implementation ViewController

{
    
    UILongPressGestureRecognizer *_longGes;
    NSString *_imgURL;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url = [[NSURL alloc]initWithString:@"http://pic.sogou.com/?p=40030500&w="];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.MyWebView loadRequest:request];
    

    
    if (_longGes == nil) {
        _longGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(getPic:)];
        _longGes.minimumPressDuration = 1;
        _longGes.delegate = self;
        _longGes.allowableMovement = 15;
        _longGes.numberOfTouchesRequired = 1;
        _longGes.cancelsTouchesInView = true;
        [self.MyWebView addGestureRecognizer:_longGes];
    }

}

//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return true;
}

-(void)getPic:(UILongPressGestureRecognizer *)recognizer
{
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self.MyWebView];
    
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.MyWebView stringByEvaluatingJavaScriptFromString:imgURL];
    _imgURL = urlToSave;
    if (urlToSave.length == 0) {
        return;
    }
    
    [self handleLongTouch];
    
}


- (void)handleLongTouch {
    NSLog(@"%@", _imgURL);
    
    UIActionSheet* sheet =[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons - 1 == buttonIndex) {
        return;
    }
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"保存图片"]) {
        if (_imgURL) {
            NSLog(@"imgurl = %@", _imgURL);
        }
        NSURL *url = [NSURL URLWithString:_imgURL];
        
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
        
        NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
        
        NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                return ;
            }
            
            NSData * imageData = [NSData dataWithContentsOfURL:location];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage * image = [UIImage imageWithData:imageData];
                
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            });
        }];
        
        [task resume];
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        NSLog(@"Error");
    }else {
        NSLog(@"OK");
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"保存成功!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}




@end
