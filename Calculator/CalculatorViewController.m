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
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize displayBrain = _displayBrain;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userHasEnteredADecimalDot = _userHasEnteredADecimalDot;
@synthesize brain = _brain;

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
    [self.brain pushOperand:[self.display.text doubleValue]];
    
    // Save the history in the displayBrain label
    self.displayBrain.text = [self.displayBrain.text stringByAppendingString:[@" " stringByAppendingString:self.display.text]];
    
    
    // Get ready to type in new numbers!
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasEnteredADecimalDot = NO;
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    // Add the operation name to the history string
    self.displayBrain.text = [self.displayBrain.text stringByAppendingString:[@" " stringByAppendingString:sender.currentTitle]];
    
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
}

- (IBAction)clearPressed
{
    self.display.text = @"";
    self.displayBrain.text = @"";
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasEnteredADecimalDot = NO;
    
    [self.brain clearOperandStack];
}

- (void)viewDidUnload {
    [self setDisplayBrain:nil];
    [super viewDidUnload];
}
@end
