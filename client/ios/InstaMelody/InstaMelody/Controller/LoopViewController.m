//
//  LoopViewController.m
//  InstaMelody
//
//  Created by Ahmed Bakir on 8/17/15.
//  Copyright (c) 2015 InstaMelody. All rights reserved.
//

#import "LoopViewController.h"
#import "DataManager.h"
#import "MelodyGroup.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "AFURLSessionManager.h"
#import "constants.h"
#import <AVFoundation/AVFoundation.h>

@interface LoopViewController ()

@property (nonatomic, strong) NSArray *groupArray;
@property (nonatomic, strong) Melody *selectedMelody;

@property (nonatomic, strong) AVAudioPlayer *bgPlayer;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong)  NSDate *startTime;

@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation LoopViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupArray = [[DataManager sharedManager] melodyGroupList];
    [self roundView:self.profileImageView];
    [self roundView:self.centerConsoleView];
    [self roundView:self.consoleView];
    
    [self applyFontAwesome];
    
    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.progressTintColor = [UIColor colorWithRed:1/255.0f green:174/255.0f blue:255/255.0f alpha:1.0f];
    self.progressView.thicknessRatio = 0.1f;
    
}

-(void)roundView:(UIView *)view {
    view.layer.cornerRadius = view.frame.size.height / 2;
    view.layer.masksToBounds = YES;
}

-(void)updatePlaybackProgress {
    [self.progressView setProgress:self.bgPlayer.currentTime/self.bgPlayer.duration animated:YES];
}

-(void)updateRecordProgress {
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.startTime];
    
    if (interval > 10) {
        self.startTime = [NSDate date];
        interval = 0;
    }
    [self.progressView setProgress:interval/10.0f animated:YES];
}

-(void)applyFontAwesome {
    self.playButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:50.0f];
    
    self.playButton.hidden = YES;
    
    self.shareButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:35.0f];
    self.playLoopButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:25.0f];
    
    [self.playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconPlay] forState:UIControlStateNormal];
    [self.playLoopButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconRefresh] forState:UIControlStateNormal];
    [self.shareButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconShareAlt] forState:UIControlStateNormal];
    
    [self.volumeBarButtonItem setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontAwesomeFontOfSize:20.0f]
                                         } forState:UIControlStateNormal];
    [self.volumeBarButtonItem setTitle:[NSString fontAwesomeIconStringForEnum:FAIconVolumeUp]];
    
    
}

-(IBAction)chooseLoop:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Loops" message:@"Choose a loop" preferredStyle:UIAlertControllerStyleActionSheet];
    
    MelodyGroup *group = self.groupArray[0];
    
    if (group != nil) {
        
        for (Melody *melody in group.melodies) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:melody.melodyName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //make the button do something
                [self didSelectMelody:melody];
                
            }];
            [alert addAction:action];
            
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
        [alert addAction:cancelAction];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)share:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share to" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *fbAction = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //sdf
    }];
    
    UIAlertAction *twAction = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //sdf
    }];
    
    UIAlertAction *scAction = [UIAlertAction actionWithTitle:@"SoundCloud" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //sdf
    }];
    
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle:@"E-mail" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //sdf
    }];
    
    UIAlertAction *textAction = [UIAlertAction actionWithTitle:@"Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //sdf
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [alert addAction:fbAction];
    [alert addAction:twAction];
    [alert addAction:scAction];
    [alert addAction:emailAction];
    [alert addAction:textAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)showVolumeSettings:(id)sender {
    
}

-(IBAction)playLoop:(id)sender {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *pathString = [NSString stringWithFormat:@"%@/Melodies/%@", documentsPath, self.selectedMelody.fileName];
    
    //pathString = [pathString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *docURL = [NSURL fileURLWithPath:pathString];
    
    NSError *error = nil;
    
    self.bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:docURL error:&error];
    
    if (error == nil) {
        
        [self.playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconStop] forState:UIControlStateNormal];
        [self.bgPlayer setNumberOfLoops:-1];
        [self.bgPlayer play];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
    } else {
        NSLog(@"Error loading file: %@", [error description]);
        
    }

}

-(IBAction)toggleRecording:(id)sender {
    if (self.recorder.isRecording) {
        
        [self.recorder stop];
        
        [self.timer invalidate];
        
    } else {
        NSError *error;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            error:&error];
        if (error == nil) {
            NSArray *paths =
            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0];
            
            NSString *recordingPath = [documentsPath stringByAppendingPathComponent:@"Recordings"];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:recordingPath]){
                
                NSError* error;
                if(  [[NSFileManager defaultManager] createDirectoryAtPath:recordingPath withIntermediateDirectories:NO attributes:nil error:&error]) {
                    
                    NSLog(@"success creating folder");
                    
                } else {
                    NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
                    NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
                }
                
            }
            
            time_t unixTime = time(NULL);
            
            NSString *fileName = [NSString stringWithFormat:@"recording_%d.wav", (int)unixTime];
            
            NSString *filePath = [recordingPath
                                  stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            NSMutableDictionary *settingsDict = [NSMutableDictionary new];
            [settingsDict setObject:[NSNumber numberWithInt:44100.0]
                             forKey:AVSampleRateKey];
            [settingsDict setObject:[NSNumber numberWithInt:2]
                             forKey:AVNumberOfChannelsKey];
            [settingsDict setObject:[NSNumber
                                     numberWithInt:AVAudioQualityMedium]
                             forKey:AVEncoderAudioQualityKey];
            
            [settingsDict setObject:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
            
            [settingsDict setObject:[NSNumber numberWithInt:16]
                             forKey:AVEncoderBitRateKey];
            self.recorder = [[AVAudioRecorder alloc]
                             initWithURL:fileURL
                             settings:settingsDict error:&error];
            if (error == nil) {
                NSLog(@"audio recorder initialized successfully!");
                
                [self.recorder record];
                
                self.startTime = [NSDate date];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateRecordProgress) userInfo:nil repeats:YES];
            } else {
                NSLog(@"error initializing audio recorder: %@",
                      [error description]);
            }
        } else {
            NSLog(@"error initializing audio session: %@",
                  [error description]);
        }
        
    }
}

-(IBAction)togglePlayback:(id)sender {
    //sdf
    
    if ([self.bgPlayer isPlaying]) {
        
        [self.bgPlayer stop];
        [self.playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAIconPlay] forState:UIControlStateNormal];
        
        [self.timer invalidate];
    } else {
        
        if ([self isHeadsetPluggedIn]) {
            [self playLoop:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Headphones not detected" message:@"For the best results, please plug in your headphones" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self playLoop:nil];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
    }
}

-(void)didSelectMelody:(Melody *)melody {
    [self.chooseLoopButton setTitle:melody.melodyName forState:UIControlStateNormal];
    
    [self loadMelody:melody];
}

-(void)loadMelody:(Melody *)melody {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *melodyPath = [documentsPath stringByAppendingPathComponent:@"Melodies"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:melodyPath]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:melodyPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            
            NSLog(@"success creating folder");
            
        } else {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
        
    }
    
    
    NSURL *docURL = [NSURL fileURLWithPath:documentsPath];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:docURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    
    
    NSString *pathString = [melodyPath stringByAppendingPathComponent:melody.fileName];
    
    //NSString *filePath = [documentsPath stringByAppendingPathComponent:pathString];
    
    self.selectedMelody = melody;
    
    //if file exists, load, set status = loaded,
    if ([fileManager fileExistsAtPath:pathString]) {
        //
        
        self.loopStatusLabel.text = @"Loop loaded!";
        
        self.playButton.hidden = NO;
        
    } else {
        //else, download, show progress, set loaded, set play button
        
        self.loopStatusLabel.text = @"Loop downloading (0%)";
        
        [self downloadFile:melody.filePathUrlString toPath:pathString];
    }
}

-(void)downloadFile:(NSString *)sourceFilePath toPath:(NSString *)destinationFilePath {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *fullUrlString = [NSString stringWithFormat:@"%@/%@", DOWNLOAD_BASE_URL, sourceFilePath];
    fullUrlString = [fullUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *URL = [NSURL URLWithString:fullUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSProgress *progress = nil;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        //NSString *fileString = [NSString stringWithFormat:@"file://%@", destinationFilePath];
        NSURL *fileURL = [NSURL fileURLWithPath:destinationFilePath];
        
        return fileURL;
         
        //NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        //return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (error == nil) {
            NSLog(@"File downloaded to: %@", filePath);
            self.loopStatusLabel.text = @"Loop loaded!";
            
            self.playButton.hidden = NO;
        } else {
            NSLog(@"Download error: %@", error.description);
            self.loopStatusLabel.text = @"Error loading loop";
        }
        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
    }];
    [downloadTask resume];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Wants to update UI or perform any task on main thread.
            double percent = progress.fractionCompleted * 100.0;
            self.loopStatusLabel.text = [NSString stringWithFormat:@"Loop downloading (%.0f%%)", percent];
        });
        
        NSLog(@"Progress… %f", progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

@end
