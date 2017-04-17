//
//  RandomPassword.m
//  LuckyPicker
//
//  Created by BangshengXie on 18/04/2017.
//  Copyright © 2017 BangshengXie. All rights reserved.
//

#import "RandomPassword.h"
#import "Random.h"

@interface RandomPassword()

@property (strong, nonatomic) Random *random;
@property (strong, nonatomic) NSMutableString *letters;
@property (strong, nonatomic) NSString *lettersWithNumber;
@property (strong, nonatomic) NSString *lettersWithCharacter;

@end

@implementation RandomPassword

#pragma mark - lazy instantiation

- (Random*)random
{
    if(!_random)
    {
        _random = [[Random alloc] init];
    }
    return _random;
}

- (NSMutableString*)letters
{
    if(!_letters)
    {
        _letters = [[NSMutableString alloc] init];
    }
    return _letters;
}

- (NSString*)lettersWithNumber
{
    if(!_lettersWithNumber)
    {
        _lettersWithNumber = @"0123456789";
    }
    return _lettersWithNumber;
}

- (NSString*)lettersWithCharacter
{
    if(!_lettersWithCharacter)
    {
        _lettersWithCharacter = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    }
    return _lettersWithCharacter;
}

- (void)setIsNumber:(Boolean)isNumber
{
    if(_isNumber != isNumber)
    {
        _isNumber = isNumber;
        [self resetLetters];
    }
}

- (void)setIsCharacter:(Boolean)isCharacter
{
    if(_isCharacter != isCharacter)
    {
        _isCharacter = isCharacter;
        [self resetLetters];
    }
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if(self)
    {
        self.length = 0;
        self.isNumber = true;
        self.isCharacter = true;
    }
    return self;
}

#pragma mark - generate

- (NSString*)generatePassword
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:self.length];
    NSInteger lettersAmount = [self.letters length];
    if(lettersAmount == 0)
        return @"";
    
    self.random.toValue = (int32_t)lettersAmount - 1;
    
    for(int i = 0; i < self.length; i++)
    {
        [randomString appendFormat:@"%C", [self.letters characterAtIndex:[self.random generate]]];
    }
    return [randomString copy];
}

- (void)resetLetters
{
    [self.letters setString:@""];
    if(self.isNumber)
        [self.letters appendString:self.lettersWithNumber];
    if(self.isCharacter)
        [self.letters appendString:self.lettersWithCharacter];
}

@end
