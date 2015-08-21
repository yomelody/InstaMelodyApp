//
//  DataManager.m
//  
//
//  Created by Ahmed Bakir on 8/17/15.
//
//

#import "DataManager.h"
#import "Constants.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"

@implementation DataManager

+ (id)sharedManager {
    static DataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.dateFormatter =  [[NSDateFormatter alloc] init];
        
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        
        [sharedMyManager.dateFormatter setLocale:enUSPOSIXLocale];
        
        [sharedMyManager.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [sharedMyManager.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
    return sharedMyManager;
}



- (void)fetchFriends {
    NSString *requestUrl = [NSString stringWithFormat:@"%@/User/Friends", API_BASE_URL];
    
    NSString *token =  [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
    
    //add 64 char string
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"token": token};
    
    [manager GET:requestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *friendsList = (NSArray *)responseObject;
        
        [self updateFriends:friendsList];
        
        
        //NSDictionary *responseDict = (NSDictionary *)responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error fetching friends: %@", error);
        
    }];
}

- (void)updateFriends:(NSArray *)friendsList {
    [Friend MR_truncateAll];
    
    for (NSDictionary *friendDict in friendsList) {
        Friend *newFriend = [Friend MR_createEntity];
        newFriend.firstName = [friendDict objectForKey:@"FirstName"];
        newFriend.lastName = [friendDict objectForKey:@"LastName"];
        newFriend.userId = [friendDict objectForKey:@"Id"];
        newFriend.displayName = [friendDict objectForKey:@"DisplayName"];
        
        if ([friendDict objectForKey:@"Image"] != nil) {
            NSDictionary *imageDict = [friendDict objectForKey:@"Image"];
            newFriend.profileFilePath = [imageDict objectForKey:@"FilePath"];
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        if (error == nil) {
            NSLog(@"CORE DATA save - successful");
            
            
            //fetch profiles
            [self downloadProfilePictures];
            
        } else {
            NSLog(@"CORE DATA error - %@", error.description);
        }
        //
    }];
    
}

-(void)downloadProfilePictures {
    
    //try to create folder
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *profilePath = [documentsPath stringByAppendingPathComponent:@"Profiles"];
    
    if (![fileManager fileExistsAtPath:profilePath]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:profilePath withIntermediateDirectories:NO attributes:nil error:&error]) {
            
            NSLog(@"success creating folder");
            
        } else {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
        
    }
    
    NSArray *friendList = [Friend MR_findAll];
    
    for (Friend *friend in friendList) {
        if (friend.profileFilePath != nil) {
            NSString *fileName = [friend.profileFilePath lastPathComponent];
            NSString *pathString = [profilePath stringByAppendingPathComponent:fileName];
            
            if (![fileManager fileExistsAtPath:pathString]) {
                
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                
                NSString *fullUrlString = [NSString stringWithFormat:@"%@/%@", DOWNLOAD_BASE_URL, friend.profileFilePath];
                fullUrlString = [fullUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                
                NSURL *URL = [NSURL URLWithString:fullUrlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                
                NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    
                    //NSString *fileString = [NSString stringWithFormat:@"file://%@", destinationFilePath];
                    NSURL *fileURL = [NSURL fileURLWithPath:pathString];
                    
                    return fileURL;
                    
                    //NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                    //return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    
                    if (error == nil) {
                        NSLog(@"File downloaded to: %@", filePath);
                        
                    } else {
                        NSLog(@"Download error: %@", error.description);
                    }
                }];
                [downloadTask resume];
                
            }
            
            
        }
    }
    
}

- (NSArray *)friendList {
    return [Friend MR_findAll];
}

#pragma mark - melodies

-(void)fetchMelodies {
    NSString *requestUrl = [NSString stringWithFormat:@"%@/Melody", API_BASE_URL];
    
    NSString *token =  [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
    
    //add 64 char string
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"token": token};
    
    [manager GET:requestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // NSLog(@"JSON: %@", responseObject);
        NSLog(@"melodies updated");
        
        NSArray *melodyList = (NSArray *)responseObject;
        
        [self updateMelodies:melodyList];
        
        
        //NSDictionary *responseDict = (NSDictionary *)responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error fetching friends: %@", error);
        
    }];
}

- (void)updateMelodies:(NSArray *)melodyList {
    [MelodyGroup MR_truncateAll];
    [Melody MR_truncateAll];
    
    for (NSDictionary *melodyGroupDict in melodyList) {
        
        MelodyGroup *newGroup = [MelodyGroup MR_createEntity];
        newGroup.groupName = [melodyGroupDict objectForKey:@"Name"];
        newGroup.groupId = [melodyGroupDict objectForKey:@"Id"];
        
        NSString *dateString = [melodyGroupDict objectForKey:@"DateModified"];
        dateString = [dateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        
        newGroup.dateModified = date;
        
        //create melodies
        
        NSArray *melodyArray = [melodyGroupDict objectForKey:@"Melodies"];
        for (NSDictionary *melodyDict in melodyArray) {
            Melody *newMelody = [Melody MR_createEntity];
            newMelody.melodyName = [melodyDict objectForKey:@"Name"];
            //newMelody.melodyDesc = [melodyDict objectForKey:@"Description"];
            newMelody.melodyId = [melodyDict objectForKey:@"Id"];
            newMelody.fileName = [melodyDict objectForKey:@"FileName"];
            newMelody.filePathUrlString = [melodyDict objectForKey:@"FilePath"];
            newMelody.isUserCreated = [melodyDict objectForKey:@"IsUserCreated"];
            
            NSString *dateString = [melodyDict objectForKey:@"DateModified"];
            dateString = [dateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSDate *date = [self.dateFormatter dateFromString:dateString];

            newMelody.dateModified = date;
            
            newMelody.melodyGroup = newGroup;
        }
        
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        if (error == nil) {
            NSLog(@"CORE DATA save - successful");
        } else {
            NSLog(@"CORE DATA error - %@", error.description);
        }
        //
    }];
}

-(NSArray *)melodyList {
    return [Melody MR_findAll];
}

-(NSArray *)melodyGroupList {
    return [MelodyGroup MR_findAllSortedBy:@"groupId" ascending:YES];
}

@end