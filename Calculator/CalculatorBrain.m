//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Marcus Stenbeck on 2012-07-18.
//  Copyright (c) 2012 Macatak Media. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
// NSMutableArray allows us to add and remove things to the array, hence "Mutable"
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray*)operandStack
{
    if (_operandStack == nil) _operandStack = [[NSMutableArray alloc] init];
    return _operandStack;
}

- (void)setOperandStack:(NSMutableArray *)operandStack
{
    _operandStack = operandStack;
}

- (void)clearOperandStack
{
    [self.operandStack removeAllObjects];
}

- (void)pushOperand:(double)operand
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if(operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];
}

- (double)performOperation:(NSString *)operation
{
    double result = 0;

    // Calculate result
    if([operation isEqualToString:@"+"])
    {
        result = [self popOperand] + [self popOperand];
    }
    else if([operation isEqualToString:@"*"])
    {
        result = [self popOperand] * [self popOperand];
    }
    else if([operation isEqualToString:@"-"])
    {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    }
    else if([operation isEqualToString:@"/"])
    {
        double divisor = [self popOperand];
        if(divisor == 0) divisor = 1;
        result = [self popOperand] / divisor;
    }
    else if([operation isEqualToString:@"π"])
    {
        result = M_PI;
    }
    else if([operation isEqualToString:@"sqrt"])
    {
        double number = [self popOperand];
        if(number > 0)
            number = sqrt(number);
        result = number;
    }
    else if([operation isEqualToString:@"sin"])
    {
        result = sin([self popOperand]);
    }
    else if([operation isEqualToString:@"cos"])
    {
        result = cos([self popOperand]);
    }
    
    [self pushOperand:result];
    
    return result;
}

@end
