
//  AKOMultiColumnTextView.m
//  CoreTextWrapper
//
//  Created by Adrian on 4/24/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "AKOMultiColumnTextView.h"
#import "UIFont+CoreTextExtensions.h"

@interface AKOMultiColumnTextView ()

@property (nonatomic, retain) NSMutableAttributedString *attributedString;
@property (nonatomic, retain) NSMutableArray *attributedStrings;

- (void)updateAttributedString;
- (void)updateFrames;
- (void)setup;
- (void)createColumns;
- (void)setPage:(NSInteger)page;
@end


@implementation AKOMultiColumnTextView

@dynamic font;
@dynamic columnCount;
@dynamic text;
@dynamic texts;
@dynamic color;
@synthesize startIndex = _startIndex;
@synthesize finalIndex = _finalIndex;
@synthesize moreTextAvailable = _moreTextAvailable;
@synthesize attributedString = _attributedString;
@synthesize attributedStrings = _attributedStrings;

@synthesize lineBreakMode = _lineBreakMode;
@synthesize textAlignment = _textAlignment;
@synthesize firstLineHeadIndent = _firstLineHeadIndent;
@synthesize spacing = _spacing;
@synthesize topSpacing = _topSpacing;
@synthesize lineSpacing = _lineSpacing;
@synthesize columnInset = _columnInset;

@synthesize dataSource = _dataSource;
@synthesize touchTimer;
#pragma mark -
#pragma mark Init and dealloc
- (void) longPress:(UILongPressGestureRecognizer *) gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Item" action:@selector(menuItemClicked:)];
        
        NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void) copy:(id) sender {
    // called when copy clicked in menu
    NSLog(@"copy");
    
}
- (void) select:(id) sender {
    // called when copy clicked in menu
    NSLog(@"selectAll");
    
}
- (void) selectAll:(id) sender {
    // called when copy clicked in menu
    NSLog(@"selectAll");
    
}
- (void) menuItemClicked:(id) sender {
    // called when Item clicked in menu
    NSLog(@"Meny item clicked");
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(cut:))
        return NO;
    else if (action == @selector(copy:))
        return YES;
    else if (action == @selector(paste:))
        return NO;
    else if (action == @selector(select:) || action == @selector(selectAll:))
        return YES;
    else
        return [super canPerformAction:action withSender:sender];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    _columnCount = 3;
    _text = [@"" copy];
    _font = [UIFont fontWithName:@"Helvetica" size:14.0];
    _color = [UIColor blackColor];
    _startIndex = 0;
    _finalIndex = 0;
    _moreTextAvailable = NO;
    _columnPaths = NULL;
    _frames = NULL;
    
    _attributedStrings = [[NSMutableArray alloc] init];
    _lineBreakMode = kCTLineBreakByWordWrapping;
    _textAlignment = kCTTextAlignmentLeft;
    _firstLineHeadIndent = 0.0;
    _spacing = 5.0;
    _topSpacing = 3.0;
    _lineSpacing = 1.0;
    _columnInset = CGPointMake(10.0, 10.0);
//    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    [self addGestureRecognizer:gr];
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc 
{
    if (_columnPaths != NULL)
    {
        CFRelease(_columnPaths);
    }
    
    if (_frames != NULL)
    {
        CFRelease(_frames);
    }
    
    self.dataSource = nil;
    self.attributedString = nil;
    self.attributedStrings = nil;

    _text = nil;
    _font = nil;
    _color = nil;
    loop = nil;

}

#pragma mark -
#pragma mark Properties

- (UIColor *)color
{
    return _color;
}

- (void)setColor:(UIColor *)newColor
{
    _color = newColor;
    [self updateFrames];
    [self setNeedsDisplay];
}

- (UIFont *)font
{
    return _font;
}

- (void)setFont:(UIFont *)newFont
{
    if (newFont != _font)
    {
        _font = newFont;
        [self updateFrames];
        [self setNeedsDisplay];
    }
}

- (NSString *)text
{
    return _text;
}

- (NSArray *)texts
{
    return _texts;
}

- (void)setDataSource:(id<AKOMultiColumnTextViewDataSource>)dataSource
{
//    if (![_dataSource isEqual:dataSource])
//    {
//        _dataSource = dataSource;
//         if (dataSource != nil)
//         {
//             [self updateFrames];
//             [self setNeedsDisplay];
//         }
//    }
    _dataSource = dataSource;
    if (dataSource != nil)
    {
        [self updateFrames];
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)newText
{
    if (![_text isEqualToString:newText])
    {
        _text = [newText copy];
        
        self.attributedString = nil;
        [self updateFrames];
        [self setNeedsDisplay];
    }
}

- (void)setTexts:(NSArray *)newTexts
{
    if (![_texts isEqual:newTexts])
    {
        _text = nil;
        
        _texts = [newTexts copy];
        
        self.attributedString = nil;
        [self updateFrames];
        [self setNeedsDisplay];
    }
}

- (NSInteger)columnCount
{
    return _columnCount;
}

- (void)setColumnCount:(NSInteger)newColumnCount
{
    if (_columnCount != newColumnCount)
    {
        _columnCount = newColumnCount;
        [self updateFrames];
        [self setNeedsDisplay];
    }
}



#pragma mark -
#pragma mark Drawing methods

- (void)drawRect:(CGRect)rect 
{
    // Initialize the text matrix to a known value.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // This is required, otherwise the text is drawn upside down in iPhone OS 3.2 (!?)
    CGContextSaveGState(context);
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height);
    CGContextConcatCTM(context, flip);
    CFIndex pathCount = CFArrayGetCount(_columnPaths);
    
    for (int column = 0; column < pathCount; column++)
    {
        CTFrameRef frame = (CTFrameRef)CFArrayGetValueAtIndex(_frames, column);
        CTFrameDraw(frame, context);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Private methods

- (void)createColumns
{
    
    int column;
    CGRect* columnRects = (CGRect*)calloc(_columnCount, sizeof(*columnRects));
    
    // Start by setting the first column to cover the entire view.
    columnRects[0] = self.bounds;

    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(self.bounds) / _columnCount;
    for (column = 0; column < _columnCount - 1; column++) 
    {
        CGRectDivide(columnRects[column], 
                     &columnRects[column],
                     &columnRects[column + 1], 
                     columnWidth, 
                     CGRectMinXEdge);
    }
    
    // Inset all columns by a few pixels of margin.
    for (column = 0; column < _columnCount; column++) 
    {
        columnRects[column] = CGRectInset(columnRects[column], _columnInset.x, _columnInset.y);
    }
    
    // Create an array of layout paths, one for each column.
    if (_columnPaths != NULL)
    {
        CFRelease(_columnPaths);
    }
    _columnPaths = CFArrayCreateMutable(kCFAllocatorDefault, _columnCount, &kCFTypeArrayCallBacks);
    for (column = 0; column < _columnCount; column++) 
    {
        CGMutablePathRef path = CGPathCreateMutable();
        
       
        // ask the delegate here
        UIView *columnView = nil;
        if ([self.dataSource respondsToSelector:@selector(akoMultiColumnTextView:viewForColumn:onPage:)])
        {
            columnView = [self.dataSource akoMultiColumnTextView:self viewForColumn:column onPage:_page];
        }
        if (columnView != nil)
        {
            CGRect columnRect = columnRects[column];
//            if (column == 1 || column == 2) {
//                columnRect.origin.y = columnView.frame.size.height;
//            }
            CGRect rectFromView = columnView.frame;
            CGFloat cutLine = 0;
            CGFloat drawYOffset = 0;
            BOOL drawAbove = YES;
            
            
            if (rectFromView.origin.y < 0)
            {
                cutLine = rectFromView.origin.y+rectFromView.size.height + _columnInset.y;
            }
            else if (rectFromView.origin.y+rectFromView.size.height >= columnRect.size.height)
            {
                cutLine = columnRect.size.height-(columnRect.size.height - rectFromView.origin.y) - _columnInset.y;  
                drawAbove = NO;
                drawYOffset = columnRect.size.height-cutLine + _columnInset.y; 
            }
            else
            {
                cutLine = rectFromView.size.height+_columnInset.y;  
            }

            CGRect rectToDraw1;
            CGRect rectToDraw2;
            CGRectDivide(columnRect, 
                         &rectToDraw1,
                         &rectToDraw2,
                         cutLine, 
                         CGRectMinYEdge);
            
            
            
            CGRect drawRect = rectToDraw1;
            if (drawAbove == YES)
            {
                drawRect = rectToDraw2;
            }
            
            CGPathAddRect(path, NULL, CGRectMake(drawRect.origin.x,drawYOffset +_columnInset.y, drawRect.size.width, drawRect.size.height-_columnInset.y));
            
            // Not add the desired view on the column
            columnView.frame = CGRectMake(drawRect.origin.x,
                                          columnView.frame.origin.y + _columnInset.y,
                                          columnView.frame.size.width,
                                          columnView.frame.size.height);
            CGFloat byTwoWidth = columnWidth + columnWidth;
            CGRect rect = columnView.frame;
            rect.size.width = byTwoWidth-30;
            columnView.frame = rect;
            if (column == 1)
            {
                 [self addSubview:columnView];
            }
           
        }
        else
        {
            CGPathAddRect(path, NULL, columnRects[column]);
        }
        
        CFArrayInsertValueAtIndex(_columnPaths, column, path);
        CFRelease(path);
    }
    free(columnRects);
    

}

- (void)updateAttributedString
{
    if (self.text != nil)
    {
        self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        NSRange range = NSMakeRange(0, [self.text length]);
        
        if (self.font != nil)
        {
            CTFontRef font = [self.font createCTFont];
            [self.attributedString addAttribute:(NSString *)kCTFontAttributeName
                                          value:(__bridge id)font
                                          range:range];
            CFRelease(font);
        }
        
        if (self.color != nil)
        {
            [self.attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName 
                                          value:(id)self.color.CGColor
                                          range:range];
        }
        
        
        CFIndex theNumberOfSettings = 6;
        CTParagraphStyleSetting theSettings[6] =
        {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment },
            { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
            { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &_firstLineHeadIndent },
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_spacing },
            { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &_topSpacing },
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_lineSpacing }
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
        [self.attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName 
                                      value:(id)paragraphStyle
                                      range:range];
        
        CFRelease(paragraphStyle);
    }
}


- (NSMutableAttributedString *)newAttributedStringWithString:(NSString *)aString
{
    NSMutableAttributedString *attributedString = nil;
    if (aString != nil)
    {
        attributedString = [[NSMutableAttributedString alloc] initWithString:aString];
        NSRange range = NSMakeRange(0, [aString length]);
        
        if (self.font != nil)
        {
            CTFontRef font = [self.font createCTFont];
            [attributedString addAttribute:(NSString *)kCTFontAttributeName
                                     value:(__bridge id)font
                                     range:range];
            CFRelease(font);
        }
        
        if (self.color != nil)
        {
            [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
                                     value:(id)self.color.CGColor
                                     range:range];
        }
        
        
        CFIndex theNumberOfSettings = 6;
        CTParagraphStyleSetting theSettings[6] =
        {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment },
            { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
            { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &_firstLineHeadIndent },
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_spacing },
            { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &_topSpacing },
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &_lineSpacing }
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
        [attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                                 value:(id)paragraphStyle
                                 range:range];
        
        CFRelease(paragraphStyle);
    }
    return attributedString;
}


- (void)updateFrames
{
    if (self.text != nil)
    {
        [self updateAttributedString];
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
        [self createColumns];
        
        CFIndex pathCount = CFArrayGetCount(_columnPaths);
        CFIndex currentIndex = self.startIndex;
        
        if (_frames != NULL)
        {
            CFRelease(_frames);
        }
        _frames = CFArrayCreateMutable(kCFAllocatorDefault, pathCount, &kCFTypeArrayCallBacks);
        
        for (int column = 0; column < pathCount; column++)
        {
            CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(_columnPaths, column);
            
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(currentIndex, 0), path, NULL);
            CFArrayInsertValueAtIndex(_frames, column, frame);
            
            CFRange frameRange = CTFrameGetVisibleStringRange(frame);
            currentIndex += frameRange.length;
            CFRelease(frame);
        }
        
        _finalIndex = currentIndex;
        _moreTextAvailable = [self.text length] > self.finalIndex;
        CFRelease(framesetter);
    }
    else if (self.texts != nil)
    {
        [_attributedStrings removeAllObjects];
        for (int column = 0; column < _columnCount; column++)
        {
            if (column < [_texts count])
            {
                NSString *currentText = [_texts objectAtIndex:column];
                [_attributedStrings addObject:[self newAttributedStringWithString:currentText]];
            }
        }
        [self createColumns];
        CFIndex pathCount = CFArrayGetCount(_columnPaths);
        
        if (_frames != NULL)
        {
            CFRelease(_frames);
        }
        _frames = CFArrayCreateMutable(kCFAllocatorDefault, pathCount, &kCFTypeArrayCallBacks);
        
        for (int column = 0; column < pathCount; column++)
        {
            if (column < [_attributedStrings count])
            {
                CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)[_attributedStrings objectAtIndex:column]);
                
                CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(_columnPaths, column);
                
                CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
                CFArrayInsertValueAtIndex(_frames, column, frame);
                
                CFRelease(frame);
                CFRelease(framesetter);
            }
        }
        
        _moreTextAvailable = NO;
    }
}

- (void)setPage:(NSInteger)page
{
    _page = page;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(addLoop)
                                                     userInfo:nil
                                                      repeats:NO];
    
    // just create one loop and re-use it.
    if(loop == nil){
        loop = [[MagnifierView alloc] init];
        loop.viewToMagnify = self;
    }
    isDragged = false;
    [[UIMenuController sharedMenuController]setMenuVisible:false];
    [self.scrollView setScrollEnabled:false];
    UITouch *touch = [touches anyObject];
    loop.touchPoint = [touch locationInView:self];
    [loop setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    isDragged = true;
    [self handleAction:touches];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.scrollView setScrollEnabled:true];
    [self.touchTimer invalidate];
    [loop removeFromSuperview];
    if (isDragged == true){
        isDragged = false;
       [self addMenuItems];
    }
   
    
}

- (void)addLoop {
    // add the loop to the superview.  if we add it to the view it magnifies, it'll magnify itself!
    [self.superview addSubview:loop];
    // here, we could do some nice animation instead of just adding the subview...
}

- (void)handleAction:(id)timerObj {
    NSSet *touches = timerObj;
    UITouch *touch = [touches anyObject];
    loop.touchPoint = [touch locationInView:self];
    [loop setNeedsDisplay];
}
-(void)addMenuItems{
    UIMenuController *menuController = [UIMenuController sharedMenuController];    
    NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
    [menuController setTargetRect:CGRectMake(loop.touchPoint.x, loop.touchPoint.y, 0.0f, 0.0f) inView:self];
    [menuController setMenuVisible:YES animated:YES];
}

@end
