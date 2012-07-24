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
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray*)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)clearOperandStack
{
    [self.programStack removeAllObjects];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

/*
 *  Removed
 *
- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if(operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];
}
*/

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    // Implement
    return @"Implement in assigment 2.";
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    // Get the last object in the stack LIFO
    id topOfStack = [stack lastObject];
    
    // Remove the last object if it exists
    if(topOfStack) [stack removeLastObject];
    
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        // Calculate result
        if([operation isEqualToString:@"+"])
        {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if([operation isEqualToString:@"*"])
        {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if([operation isEqualToString:@"-"])
        {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        }
        else if([operation isEqualToString:@"/"])
        {
            double divisor = [self popOperandOffStack:stack];
            if(divisor == 0) divisor = 1;
            result = [self popOperandOffStack:stack] / divisor;
        }
        else if([operation isEqualToString:@"π"])
        {
            result = M_PI;
        }
        else if([operation isEqualToString:@"sqrt"])
        {
            double number = [self popOperandOffStack:stack];
            if(number > 0)
                number = sqrt(number);
            result = number;
        }
        else if([operation isEqualToString:@"sin"])
        {
            result = sin([self popOperandOffStack:stack]);
        }
        else if([operation isEqualToString:@"cos"])
        {
            result = cos([self popOperandOffStack:stack]);
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    
    //use introspection
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    // This may be nil the wrong class was sent to the method
    return [self popOperandOffStack:stack];
}

@end
