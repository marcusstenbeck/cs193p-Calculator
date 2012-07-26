//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Marcus Stenbeck on 2012-07-18.
//  Copyright (c) 2012 Macatak Media. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userHasEnteredADecimalDot;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *variableValues;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize displayBrain = _displayBrain;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userHasEnteredADecimalDot = _userHasEnteredADecimalDot;
@synthesize brain = _brain;
@synthesize variableValues = _variableValues;

- (NSDictionary *)variableValues
{
    if(!_variableValues) _variableValues = [[NSDictionary alloc] init];
    return _variableValues;
}

- (CalculatorBrain *)brain
{
    if(!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton*)sender
{
    NSString *digit = sender.currentTitle;
    
    if(self.userIsInTheMiddleOfEnteringANumber)
    {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else
    {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)decimalPressed:(UIButton *)sender
{
    // Exit the method if the user already has entered a decimal dot
    if(self.userHasEnteredADecimalDot) return;
    
    // Store the decimal dot label in an NSString for appending
    NSString *decimal = sender.currentTitle;
    
    // Append the decimal dot to the display label
    self.display.text = [self.display.text stringByAppendingString:decimal];
    
    // If we've come this far the decimal dot has been typed!
    self.userHasEnteredADecimalDot = YES;
    
    // ... and naturally also has started typing a number
    self.userIsInTheMiddleOfEnteringANumber = YES;
}

- (IBAction)enterPressed
{
    // Push the current number to the calculator stack
    [self.brain pushOperand:[NSNumber numberWithDouble:self.display.text.doubleValue]];
    
    // Add the operation name to the history string
    self.displayBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    // Get ready to type in new numbers!
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasEnteredADecimalDot = NO;
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    // Send the operation to the stack
    [self.brain pushOperand:sender.currentTitle];
    
    // Get the history string
    self.displayBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    // Run the program
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.variableValues];
    
    // Send results to display
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)clearPressed
{
    self.display.text = @"0";
    self.displayBrain.text = @"";
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasEnteredADecimalDot = NO;
    
    [self.brain clearOperandStack];
}

- (IBAction)variablePressed:(UIButton *)sender
{
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    // Add the operation name to the history string
    self.displayBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    // Push the variable onto the program stack
    [self.brain pushOperand:sender.currentTitle];
    
    self.variableDisplay.text = [[CalculatorBrain variablesUsedInProgram:self.brain.program] description];
}

- (IBAction)testPressed:(UIButton *)sender
{
    NSString *action = sender.currentTitle;
    
    if([action isEqualToString:@"Test1"])
    {
        self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"a", @"3", @"b", @"9", @"x", nil];
    }
    else if([action isEqualToString:@"Test2"])
    {
        self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"a", @"5", @"b", @"7", @"x", nil];
    }
}

- (void)viewDidUnload {
    [self setDisplayBrain:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}
@end
