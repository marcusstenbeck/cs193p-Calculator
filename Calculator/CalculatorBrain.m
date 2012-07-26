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

- (void)pushOperand:(id)operand
{
    if([operand isKindOfClass:[NSNumber class]])
        [self.programStack addObject:operand];
    else if([operand isKindOfClass:[NSString class]])
        [self.programStack addObject:operand];
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
    NSMutableArray *stack;
    
    if([program isKindOfClass:[NSArray class]])
        stack = [program mutableCopy];
    
    return [self descriptionOfTopOfStack:stack];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    
    // Get the last element on the stack
    id topOfStack = [stack lastObject];
    
    // Remove the last object if it's not nil - pop it off the stack
    if(topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]]) description = [NSString stringWithFormat:@"%@", topOfStack];
    else if([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        if([self isTwoOperandOperation:operation])
        {
            // Make sure subtrahend and divisor are on the correct side of the operator
            // by placing the last entered operand (first off the stack) last
            NSString *lastOperation = [self descriptionOfTopOfStack:stack];
            NSString *firstOperation = [self descriptionOfTopOfStack:stack];
            
            // Initialize format string
            NSString *format = @"";
            
            // Check if there's a need to place parentheses around the first operand
            if([self containsLowerOperationWithoutParenthesis:firstOperation operation:operation]) format = [format stringByAppendingString:@"(%@)"]; else format = [format stringByAppendingString:@"%@"];
            
            // Add operation character to format string
            format = [format stringByAppendingFormat:@" %@ ", operation];
            
            // Check if there's a need to place parentheses around the second operand
            // Special case: It may be a denominator
            if([operation isEqualToString:@"/"])
                if([self containsLowerOperationWithoutParenthesis:lastOperation operation:operation isDenominator:YES]) format = [format stringByAppendingString:@"(%@)"]; else format = [format stringByAppendingString:@"%@"];
            else
                if([self containsLowerOperationWithoutParenthesis:lastOperation operation:operation]) format = [format stringByAppendingString:@"(%@)"]; else format = [format stringByAppendingString:@"%@"];
            
            // Return the formatted string
            description = [NSString stringWithFormat:format, firstOperation, lastOperation];
        }
        else if([self isOneOperandOperation:operation])
            description = [NSString stringWithFormat:@"%@(%@)", operation, [self descriptionOfTopOfStack:stack]];
        else if([self isNoOperandOperation:operation])
            description = [NSString stringWithFormat:@"%@", operation];
        else if([self isVariable:operation])
            description = [NSString stringWithFormat:@"%@", operation];
    }
    
    return description;
}

+ (BOOL)containsLowerOperationWithoutParenthesis:(NSString *)string operation:(NSString *)operation
{
    return [self containsLowerOperationWithoutParenthesis:string operation:operation isDenominator:NO];
}

+ (BOOL)containsLowerOperationWithoutParenthesis:(NSString *)string operation:(NSString *)operation isDenominator:(BOOL)isDenominator
{
    
    // Regex to remove parentheses http://stackoverflow.com/questions/3741279/how-do-you-remove-parentheses-words-within-a-string-using-nsregularexpression
    // Explanation:
    // \(      # match an opening parenthesis
    // [^()]*  # match any number of characters except parentheses
    // \)      # match a closing parenthesis
    NSString *innermostParentheses = @"\\([^()]*\\)"; 
    
    NSString *description = string;
    
    // Remove parentheses
    // Why? Because the parentheses include cases which have already been taken care of.
    // Essentially I'm trying to prevent double parentheses.
    while([description rangeOfString:innermostParentheses options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)
    {
         description = [description stringByReplacingOccurrencesOfString:innermostParentheses withString:@"" options:NSRegularExpressionSearch|NSCaseInsensitiveSearch range:NSMakeRange(0, description.length)];
    }
    
    // Check if there's an operator in the string after removing parentheses
    NSArray *components = [description componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for(id element in components)
    {
        if([element isKindOfClass:[NSString class]])
        {
            // Is it an element
            if([self isOperation:element])
                // If it's a denominator, slap those parentheses on whatever operation it is.
                // If it's any other operation, check with precedence
                if(isDenominator || ![self isPrecedingOrEqualOperation:element comparedTo:operation]) return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isPrecedingOrEqualOperation:(NSString *)operation1 comparedTo:(NSString *)operation2
{
    NSOrderedSet *operations = [NSOrderedSet orderedSetWithObjects:@"*", @"/", @"+", @"-", nil];
    
    if([operations indexOfObject:operation1] <= [operations indexOfObject:operation2])
        return YES;
    
    return NO;
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    NSSet *twoOperandOperations = [NSSet setWithObjects:@"+", @"*", @"-", @"/", nil];
    
    if([twoOperandOperations containsObject:operation]) return YES;
    
    return NO;
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    NSSet *oneOperandOperations = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", nil];
    
    if([oneOperandOperations containsObject:operation]) return YES;
    
    return NO;
}

+ (BOOL)isNoOperandOperation:(NSString *)operation
{
    NSSet *noOperandOperations = [NSSet setWithObjects:@"π", nil];
    
    if([noOperandOperations containsObject:operation]) return YES;
    
    return NO;
}

+ (BOOL)isOperation:(NSString *)operation
{
    if([self isTwoOperandOperation:operation] || [self isOneOperandOperation:operation] || [self isNoOperandOperation:operation]) return YES;
    
    return NO;
}

+ (BOOL)isVariable:(NSString *)variable
{
    if([self isOperation:variable]) return NO;
    
    return YES;
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


// More efficient implementation?
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    
    // If program var is of type NSArray
    if([program isKindOfClass:[NSArray class]])
    {
        // Make a mutable copy and place it in the variable called stack
        stack = [program mutableCopy];
        
        // Loop through the program stack
        for(int i = 0; i < stack.count; i++)
        {
            // If the current item is a NSString it may be a variable
            if([[stack objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                // Pull out the element at the current index
                NSString *stackElement = [stack objectAtIndex:i];
                
                // If it's an operation we want to skip to the next element
                if([self isOperation:stackElement]) continue;
                
                // If the string is a key in the NSDictionary variableValues, and is of type NSNumber
                // we want to replace the stack variable with the variable value
                if([[variableValues objectForKey:stackElement] isKindOfClass:[NSNumber class]])
                {
                    NSNumber *variableValue = [variableValues objectForKey:stackElement];
                    
                    [stack replaceObjectAtIndex:i withObject:variableValue];
                }
                else
                {
                    [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                }
            }
        }
    }
    
    return [self popOperandOffStack:stack];
}

// Could this be more efficient?
+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variables = [[NSMutableSet alloc] init];
    
    // If the program is of class NSArray...
    if([program isKindOfClass:[NSArray class]])
    {
        // ... check each element in the NSArray.
        for(id programStackElement in program)
        {
            // If the current element is of class NSString...
            if([programStackElement isKindOfClass:[NSString class]])
            {
                // ... and it's not an operation
                if(![self isOperation:programStackElement])
                {
                    // It's a variable!
                    // Add it to the list of variables in the program.
                    [variables addObject:programStackElement];
                }
            }
        }
    }
    
    if(!variables.count) variables = nil;
    
    return [variables copy];
}

@end
