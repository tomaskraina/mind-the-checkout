//
//  RejseplanenStationFetcher.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/23/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "RejseplanenStationFetcher.h"
#import "APIkeys.h"
#import <AFNetworking.h>

NSString * const RejseplanenLocationPath = @"location";
NSString * const kRejseplanenName = @"name";
NSString * const kRejseplanenLatitude = @"y";
NSString * const kRejseplanenLongitude = @"x";
NSString * const kRejseplanenID = @"id";
long const RejseplanenCoordinatesMultiplier = 1000000; // 1M

@interface RejseplanenStationFetcher () <NSXMLParserDelegate>
@property (strong, nonatomic) NSString *search;
@property (strong, nonatomic) NSMutableArray *foundStations;
@property (strong, nonatomic) void (^completionBlock)(NSArray *);
//@property (strong, nonatomic) void (^errorBlock)(NSError *);
@end

@implementation RejseplanenStationFetcher

// TODO: NSXMLParser error handling
// TODO: AFHTTPClient subclass

#pragma mark - Properties

- (NSMutableArray *)foundStations
{
    if (!_foundStations) {
        _foundStations = [NSMutableArray array];
    }
    
    return _foundStations;
}

#pragma mark - Public methods

- (void)findByName:(NSString *)searchName completed:(void (^)(NSArray *))block error:(void (^)(NSError *))errorBlock
{
    NSURLRequest *request = [self urlRequestWithSearchName:searchName];
    __weak RejseplanenStationFetcher *weakSelf = self;
    AFXMLRequestOperation *requestOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        // Need to store the blocks in properties to use them in XMLParser delegate methods
        weakSelf.completionBlock = block;
//        weakSelf.errorBlock = errorBlock;
        weakSelf.foundStations = nil;
        weakSelf.search = searchName;
        XMLParser.delegate = weakSelf;
        if (![XMLParser parse]) {
            NSLog(@"XML parser error: %@", [XMLParser parserError]);
            errorBlock([[self class] errorForCode:StationFetcherErrorCodeInvalidResponse underlyingError:[XMLParser parserError]]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        NSLog(@"AFXMLRequestOperation error: %@", error);
        errorBlock([[self class] errorForCode:StationFetcherErrorCodeConnectionError underlyingError:error]);
    }];
    
    [requestOperation start];
}
#pragma mark - Error factory method

+ (NSError *)errorForCode:(StationFetcherErrorCode)code underlyingError:(NSError *)underlyingError
{
    NSString *decription, *failureReason, *recoverySuggestion;
    switch (code) {
        case StationFetcherErrorCodeInvalidResponse:
            decription = NSLocalizedStringFromTable(@"Invalid server response.", @"RejseplanenStationFetcher", nil);
            recoverySuggestion = NSLocalizedStringFromTable(@"Try to search later again and make sure you're connected to the internet.", @"RejseplanenStationFetcher", nil);
            break;
        case StationFetcherErrorCodeConnectionError:
            decription = NSLocalizedStringFromTable(@"Can't connect to the server", @"RejseplanenStationFetcher", nil);
            recoverySuggestion = NSLocalizedStringFromTable(@"Pleas check your internet connection", @"Reminder", nil);
            break;
        default:
            break;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (decription) [userInfo setObject:decription forKey:NSLocalizedDescriptionKey];
    if (failureReason) [userInfo setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
    if (recoverySuggestion) [userInfo setObject:recoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
    if (underlyingError) [userInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    
    NSError *error = [NSError errorWithDomain:StationFetcherErrorDomain code:code userInfo:userInfo];
    return error;
}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"StopLocation"]) {
        NSDictionary *stationData = [self stationDataFromXmlAttributes:attributeDict];
        [self.foundStations addObject:stationData];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Search: '%@', number of matching stations: %u", self.search, [self.foundStations count]);
    
    self.completionBlock(self.foundStations);
}

#pragma mark - Convinience methods

- (NSDictionary *)stationDataFromXmlAttributes:(NSDictionary *)attributeDict
{
    return @{kStationName: attributeDict[kRejseplanenName],
             kStationID: attributeDict[kRejseplanenID],
             kStationLatitude: [self rejseplanenToGPSCoordinate:attributeDict[kRejseplanenLatitude]],
             kStationLongitude: [self rejseplanenToGPSCoordinate:attributeDict[kRejseplanenLongitude]]
             };
}

- (NSString *)rejseplanenToGPSCoordinate:(NSString *)rejseplanenCoordinate
{
    return [NSString stringWithFormat:@"%f", [rejseplanenCoordinate doubleValue] / RejseplanenCoordinatesMultiplier];
}

- (NSURLRequest *)urlRequestWithSearchName:(NSString *)searchName
{
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:[self requestBaseUrl]];
    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:RejseplanenLocationPath parameters:@{@"input": searchName}];
    return request;
}

- (NSURL *)requestBaseUrl
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", REJSEPLANEN_BASE_URL]];
}

@end
