//
//  PrinterFunctions.m
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "PrinterFunctions.h"
#import <StarIO/SMPort.h>
#import <StarIO/SMBluetoothManager.h>
#import "RasterDocument.h"
#import "StarBitmap.h"
#import <sys/time.h>
#import <unistd.h>

@implementation PrinterFunctions

#pragma mark Open Cash Drawer

/*!
 * This function opens the cashdraw connected to the printer
 * This function just send the byte 0x07 to the printer which is the open cashdrawer command
 *
 * @param   portName        Port name to use for communication. This should be (TCP:<IPAddress>)
 * @param   portSettings    Should be blank
 */
+ (void)OpenCashDrawerWithPortname:(NSString *)portName portSettings:(NSString *)portSettings drawerNumber:(NSUInteger)drawerNumber
{
    unsigned char opencashdrawer_command = 0x00;
    
    if (drawerNumber == 1) {
        opencashdrawer_command = 0x07; //BEL
    }
    else if (drawerNumber == 2) {
        opencashdrawer_command = 0x1a; //SUB
    }
    
    NSData *commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
}


#pragma mark 1D Barcode

/**
 * This function is used to print bar codes in the 39 format
 * context - Activity for displaying messages to the user
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12).
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - The Narrow wide width of the bar code.  This value should be between 1 to 9.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCode39WithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData:(unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height narrowWide:(NarrowWide)width
{
    unsigned char n1 = 0x34;
    unsigned char n2 = 0;
    switch (option) {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case NarrowWide_2_6:
            n3 = 49;
            break;
        case NarrowWide_3_9:
            n3 = 50;
            break;
        case NarrowWide_4_12:
            n3 = 51;
            break;
        case NarrowWide_2_5:
            n3 = 52;
            break;
        case NarrowWide_3_8:
            n3 = 53;
            break;
        case NarrowWide_4_10:
            n3 = 54;
            break;
        case NarrowWide_2_4:
            n3 = 55;
            break;
        case NarrowWide_3_6:
            n3 = 56;
            break;
        case NarrowWide_4_8:
            n3 = 57;
            break;
    }
    unsigned char n4 = height;
    
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[6 + barcodeDataSize] = 0x1e;
    
    int commandSize = 6 + barcodeDataSize + 1;
    
    NSData *dataToSentToPrinter = [[NSData alloc] initWithBytes:command length:commandSize];
    
    [self sendCommand:dataToSentToPrinter portName:portName portSettings:portSettings timeoutMillis:10000];
    
    free(command);
}

/**
 * This function is used to print bar codes in the 93 format
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12).
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - This is the number of dots per module.  This value should be between 1 to 3.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCode93WithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData: (unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height min_module_dots:(Min_Mod_Size)width
{
    unsigned char n1 = 0x37;
    unsigned char n2 = 0;
    switch (option)
    {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case _2_dots:
            n3 = 49;
            break;
        case _3_dots:
            n3 = 50;
            break;
        case _4_dots:
            n3 = 51;
            break;
    }
    unsigned char n4 = height;
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[6 + barcodeDataSize] = 0x1e;
    
    int commandSize = 6 + barcodeDataSize + 1;
    
    NSData *dataToSentToPrinter = [[NSData alloc] initWithBytes:command length:commandSize];
    
    [self sendCommand:dataToSentToPrinter portName:portName portSettings:portSettings timeoutMillis:10000];
    
    free(command);
}

/**
 * This function is used to print bar codes in the ITF format
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12).
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - This is the number of dots per module.  This value should be between 1 to 3.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCodeITFWithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData:(unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height narrowWide:(NarrowWideV2)width
{
    unsigned char n1 = 0x35;
    unsigned char n2 = 0;
    switch (option)
    {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case NarrowWideV2_2_5:
            n3 = 49;
            break;
        case NarrowWideV2_4_10:
            n3 = 50;
            break;
        case NarrowWideV2_6_15:
            n3 = 51;
            break;
        case NarrowWideV2_2_4:
            n3 = 52;
            break;
        case NarrowWideV2_4_8:
            n3 = 53;
            break;
        case NarrowWideV2_6_12:
            n3 = 54;
            break;
        case NarrowWideV2_2_6:
            n3 = 55;
            break;
        case NarrowWideV2_3_9:
            n3 = 56;
            break;
        case NarrowWideV2_4_12:
            n3 = 57;
            break;
    }
    
    unsigned char n4 = height;
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[barcodeDataSize + 6] = 0x1e;
    int commandSize = 6 + barcodeDataSize + 1;
    
    NSData *dataToSentToPrinter = [[NSData alloc] initWithBytes:command length:commandSize];
    
    [self sendCommand:dataToSentToPrinter portName:portName portSettings:portSettings timeoutMillis:10000];
    
    free(command);
}

/**
 * This function is used to print bar codes in the 128 format
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12).
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - This is the number of dots per module.  This value should be between 1 to 3.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCode128WithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData:(unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height min_module_dots:(Min_Mod_Size)width
{
    unsigned char n1 = 0x36;
    unsigned char n2 = 0;
    switch (option)
    {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case _2_dots:
            n3 = 49;
            break;
        case _3_dots:
            n3 = 50;
            break;
        case _4_dots:
            n3 = 51;
            break;
    }
    unsigned char n4 = height;
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[barcodeDataSize + 6] = 0x1e;
    int commandSize = 6 + barcodeDataSize + 1;
    
    NSData *dataToSentToPrinter = [[NSData alloc] initWithBytes:command length:commandSize];
    
    [self sendCommand:dataToSentToPrinter portName:portName portSettings:portSettings timeoutMillis:10000];
    
    free(command);
}

#pragma mark 2D Barcode

/**
 * This function is used to print a qrcode on standard star printers
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * correctionLevel - The correction level for the qrcode.  The correction level can be 7, 15, 25, or 30.  See section 3-129 (Rev. 1.12).
 * model - The model to use when printing the qrcode. See section 3-129 (Rev. 1.12).
 * cellSize - The cell size of the qrcode.  This value of this should be between 1 and 8. It is recommended that this value be 2 or less.
 * barCodeData - This is the characters in the qrcode.
 * barcodeDataSize - This is the number of characters that will be written into the qrcode.  This is the size of the preceding parameter
 */
+ (void)PrintQrcodeWithPortname:(NSString*)portName portSettings:(NSString*)portSettings correctionLevel:(CorrectionLevelOption)correctionLevel model:(Model)model cellSize:(unsigned char)cellSize barcodeData:(unsigned char*)barCodeData barcodeDataSize:(unsigned int)barCodeDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char modelCommand[] = {0x1b, 0x1d, 0x79, 0x53, 0x30, 0x00};
    switch(model)
    {
        case Model1:
            modelCommand[5] = 1;
            break;
        case Model2:
            modelCommand[5] = 2;
            break;
    }
    
    [commands appendBytes:modelCommand length:6];
    
    unsigned char correctionLevelCommand[] = {0x1b, 0x1d, 0x79, 0x53, 0x31, 0x00};
    switch (correctionLevel)
    {
        case Low:
            correctionLevelCommand[5] = 0;
            break;
        case Middle:
            correctionLevelCommand[5] = 1;
            break;
        case Q:
            correctionLevelCommand[5] = 2;
            break;
        case High:
            correctionLevelCommand[5] = 3;
            break;
    }
    [commands appendBytes:correctionLevelCommand length:6];
    
    unsigned char cellCodeSize[] = {0x1b, 0x1d, 0x79, 0x53, 0x32, 0x00};
    cellCodeSize[5] = cellSize;
    [commands appendBytes:cellCodeSize length:6];
    
    unsigned char qrcodeStart[] = {0x1b, 0x1d, 0x79, 0x44, 0x31, 0x00};
    [commands appendBytes:qrcodeStart length:6];
    unsigned char qrcodeLow = barCodeDataSize % 256;
    unsigned char qrcodeHigh = barCodeDataSize / 256;
    [commands appendBytes:&qrcodeLow length:1];
    [commands appendBytes:&qrcodeHigh length:1];
    [commands appendBytes:barCodeData length:barCodeDataSize];
    
    unsigned char printQrcodeCommand[] = {0x1b, 0x1d, 0x79, 0x50};
    [commands appendBytes:printQrcodeCommand length:4];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function is used to print a pdf417 bar code in a standard star printer
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * limit - Selection of the Method to use so specify the bar code size.  This is either 0 or 1. 0 is Use Limit method and 1 is Use Fixed method. See section 3-122 of the manual (Rev 1.12).
 * p1 - The vertical proportion to use.  The value changes with the limit select.  See section 3-122 of the manual (Rev 1.12).
 * p2 - The horizontal proportion to use.  The value changes with the limit select.  See section 3-122 of the manual (Rev 1.12).
 * securityLevel - This represents how well the bar code can be recovered if it is damaged. This value should be 0 to 8.
 * xDirection - Specifies the X direction size. This value should be from 1 to 10.  It is recommended that the value be 2 or less.
 * aspectRatio - Specifies the ratio of the pdf417.  This values should be from 1 to 10.  It is recommended that this value be 2 or less.
 * barcodeData - Specifies the characters in the pdf417 bar code.
 * barcodeDataSize - Specifies the amount of characters to put in the barcode.  This should be the size of the preceding parameter.
 */
+ (void)PrintPDF417CodeWithPortname:(NSString *)portName portSettings:(NSString *)portSettings limit:(Limit)limit p1:(unsigned char)p1 p2:(unsigned char)p2 securityLevel:(unsigned char)securityLevel xDirection:(unsigned char)xDirection aspectRatio:(unsigned char)aspectRatio barcodeData:(unsigned char[])barcodeData barcodeDataSize:(unsigned int)barcodeDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char setBarCodeSize[] = {0x1b, 0x1d, 0x78, 0x53, 0x30, 0x00, 0x00, 0x00};
    switch (limit)
    {
        case USE_LIMITS:
            setBarCodeSize[5] = 0;
            break;
        case USE_FIXED:
            setBarCodeSize[5] = 1;
            break;
    }
    setBarCodeSize[6] = p1;
    setBarCodeSize[7] = p2;
    
    [commands appendBytes:setBarCodeSize length:8];
    
    unsigned char setSecurityLevel[] = {0x1b, 0x1d, 0x78, 0x53, 0x31, 0x00};
    setSecurityLevel[5] = securityLevel;
    [commands appendBytes:setSecurityLevel length:6];
    
    unsigned char setXDirections[] = {0x1b, 0x1d, 0x78, 0x53, 0x32, 0x00};
    setXDirections[5] = xDirection;
    [commands appendBytes:setXDirections length:6];
    
    unsigned char setAspectRatio[] = {0x1b, 0x1d, 0x78, 0x53, 0x33, 0x00};
    setAspectRatio[5] = aspectRatio;
    [commands appendBytes:setAspectRatio length:6];
    
    unsigned char *setBarcodeData = (unsigned char*)malloc(6 + barcodeDataSize);
    setBarcodeData[0] = 0x1b;
    setBarcodeData[1] = 0x1d;
    setBarcodeData[2] = 0x78;
    setBarcodeData[3] = 0x44;
    setBarcodeData[4] = barcodeDataSize % 256;
    setBarcodeData[5] = barcodeDataSize / 256;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        setBarcodeData[index + 6] = barcodeData[index];
    }
    [commands appendBytes:setBarcodeData length:6 + barcodeDataSize];
    free(setBarcodeData);
    
    unsigned char printBarcode[] = {0x1b, 0x1d, 0x78, 0x50};
    [commands appendBytes:printBarcode length:4];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

#pragma mark Cut

/**
 * This function is intended to show how to get a legacy printer to cut the paper
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * cuttype - The cut type to perform, the cut types are full cut, full cut with feed, partial cut, and partial cut with feed
 */
+ (void)PerformCutWithPortname:(NSString *)portName portSettings:(NSString*)portSettings cutType:(CutType)cuttype
{
    unsigned char autocutCommand[] = {0x1b, 0x64, 0x00};
    switch (cuttype)
    {
        case FULL_CUT:
            autocutCommand[2] = 48;
            break;
        case PARTIAL_CUT:
            autocutCommand[2] = 49;
            break;
        case FULL_CUT_FEED:
            autocutCommand[2] = 50;
            break;
        case PARTIAL_CUT_FEED:
            autocutCommand[2] = 51;
            break;
    }
    
    int commandSize = 3;
    
    NSData *dataToSentToPrinter = [[NSData alloc] initWithBytes:autocutCommand length:commandSize];
    
    [self sendCommand:dataToSentToPrinter portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

#pragma mark Text Formatting

/**
 * This function prints raw text to the print.  It show how the text can be formated.  For example changing its size.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * slashedZero - boolean variable to tell the printer to weather to put a slash in the zero characters that it print
 * underline - boolean variable that Tells the printer if should underline the text
 * invertColor - boolean variable that tells the printer if it should invert the text its printing.  All White space will become black and the characters will be left white
 * emphasized - boolean variable that tells the printer if it should emphasize the printed text.  This is sort of like bold but not as dark, but darker then regular characters.
 * upperline - boolean variable that tells the printer if to place a line above the text.  This only supported by new printers.
 * upsideDown - boolean variable that tells the printer if the text should be printed upside-down
 * heightExpansion - This integer tells the printer what multiple the character height should be, this should be from 0 to 5 representing multiples from 1 to 6
 * widthExpansion - This integer tell the printer what multiple the character width should be, this should be from 0 to 5 representing multiples from 1 to 6.
 * leftMargin - The left margin for the text.  Although the max value for this can be 255, the value shouldn't get that high or the text could be pushed off the page.
 * alignment - The alignment of the text. The printers support left, right, and center justification
 * textData - The text to print
 * textDataSize - The amount of text to send to the printer
 */
+ (void)PrintTextWithPortname:(NSString *)portName portSettings:(NSString*)portSettings slashedZero:(bool)slashedZero underline:(bool)underline invertColor:(bool)invertColor emphasized:(bool)emphasized upperline:(bool)upperline upsideDown:(bool)upsideDown heightExpansion:(int)heightExpansion widthExpansion:(int)widthExpansion leftMargin:(unsigned char)leftMargin alignment: (Alignment)alignment textData:(unsigned char *)textData textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char initial[] = {0x1b, 0x40};
    [commands appendBytes:initial length:2];
    
    unsigned char slashedZeroCommand[] = {0x1b, 0x2f, 0x00};
    if (slashedZero)
    {
        slashedZeroCommand[2] = 49;
    }
    else
    {
        slashedZeroCommand[2] = 48;
    }
    [commands appendBytes:slashedZeroCommand length:3];
    
    unsigned char underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline)
    {
        underlineCommand[2] = 49;
    }
    else
    {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    unsigned char invertColorCommand[] = {0x1b, 0x00};
    if (invertColor)
    {
        invertColorCommand[1] = 0x34;
    }
    else
    {
        invertColorCommand[1] = 0x35;
    }
    [commands appendBytes:invertColorCommand length:2];
    
    unsigned char emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized)
    {
        emphasizedPrinting[1] = 69;
    }
    else
    {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    unsigned char upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline)
    {
        upperLineCommand[2] = 49;
    }
    else
    {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown)
    {
        unsigned char upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    }
    else
    {
        unsigned char upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    unsigned char characterExpansion[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion[2] = heightExpansion + '0';
    characterExpansion[3] = widthExpansion + '0';
    [commands appendBytes:characterExpansion length:4];
    
    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment)
    {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function prints raw Kanji text to the print.  It show how the text can be formated.  For example changing its size.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * kanjiMode - The segment index of Japanese Kanji mode that Tells the printer to weather Shift-JIS or JIS.
 * underline - boolean variable that Tells the printer if should underline the text
 * invertColor - boolean variable that tells the printer if it should invert the text its printing.  All White space will become black and the characters will be left white
 * emphasized - boolean variable that tells the printer if it should emphasize the printed text.  This is sort of like bold but not as dark, but darker then regular characters.
 * upperline - boolean variable that tells the printer if to place a line above the text.  This only supported by new printers.
 * upsideDown - boolean variable that tells the printer if the text should be printed upside-down
 * heightExpansion - This integer tells the printer what multiple the character height should be, this should be from 0 to 5 representing multiples from 1 to 6
 * widthExpansion - This integer tell the printer what multiple the character width should be, this should be from 0 to 5 representing multiples from 1 to 6.
 * leftMargin - The left margin for the text.  Although the max value for this can be 255, the value shouldn't get that high or the text could be pushed off the page.
 * alignment - The alignment of the text. The printers support left, right, and center justification
 * textData - The text to print
 * textDataSize - The amount of text to send to the printer
 */
+ (void)PrintKanjiTextWithPortname:(NSString *)portName portSettings:(NSString*)portSettings kanjiMode:(int)kanjiMode underline:(bool)underline invertColor:(bool)invertColor emphasized:(bool)emphasized upperline:(bool)upperline upsideDown:(bool)upsideDown heightExpansion:(int)heightExpansion widthExpansion:(int)widthExpansion leftMargin:(unsigned char)leftMargin alignment:(Alignment)alignment textData:(unsigned char*)textData textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char initial[] = {0x1b, 0x40};
    [commands appendBytes:initial length:2];
    
    unsigned char kanjiModeCommand[] = {0x1b, 0x24, 0x00, 0x1b, 0x00};
    if (kanjiMode == 0)	// Shift-JIS
    {
        kanjiModeCommand[2] = 0x01;
        kanjiModeCommand[4] = 0x71;
    }
    else				// JIS
    {
        kanjiModeCommand[2] = 0x00;
        kanjiModeCommand[4] = 0x70;
    }
    [commands appendBytes:kanjiModeCommand length:5];
    
    unsigned char underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline)
    {
        underlineCommand[2] = 49;
    }
    else
    {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    unsigned char invertColorCommand[] = {0x1b, 0x00};
    if (invertColor)
    {
        invertColorCommand[1] = 0x34;
    }
    else
    {
        invertColorCommand[1] = 0x35;
    }
    [commands appendBytes:invertColorCommand length:2];
    
    unsigned char emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized)
    {
        emphasizedPrinting[1] = 69;
    }
    else
    {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    unsigned char upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline)
    {
        upperLineCommand[2] = 49;
    }
    else
    {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown)
    {
        unsigned char upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    }
    else
    {
        unsigned char upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    unsigned char characterExpansion[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion[2] = heightExpansion + '0';
    characterExpansion[3] = widthExpansion + '0';
    [commands appendBytes:characterExpansion length:4];
    
    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment)
    {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function prints raw Simplified Chinese text to the print.  It show how the text can be formated.  For example changing its size.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * underline - boolean variable that Tells the printer if should underline the text
 * invertColor - boolean variable that tells the printer if it should invert the text its printing.  All White space will become black and the characters will be left white
 * emphasized - boolean variable that tells the printer if it should emphasize the printed text.  This is sort of like bold but not as dark, but darker then regular characters.
 * upperline - boolean variable that tells the printer if to place a line above the text.  This only supported by new printers.
 * upsideDown - boolean variable that tells the printer if the text should be printed upside-down
 * heightExpansion - This integer tells the printer what multiple the character height should be, this should be from 0 to 5 representing multiples from 1 to 6
 * widthExpansion - This integer tell the printer what multiple the character width should be, this should be from 0 to 5 representing multiples from 1 to 6.
 * leftMargin - The left margin for the text.  Although the max value for this can be 255, the value shouldn't get that high or the text could be pushed off the page.
 * alignment - The alignment of the text. The printers support left, right, and center justification
 * textData - The text to print
 * textDataSize - The amount of text to send to the printer
 */
+ (void)PrintCHSTextWithPortname:(NSString *)portName portSettings:(NSString*)portSettings underline:(bool)underline invertColor:(bool)invertColor emphasized:(bool)emphasized upperline:(bool)upperline upsideDown:(bool)upsideDown heightExpansion:(int)heightExpansion widthExpansion:(int)widthExpansion leftMargin:(unsigned char)leftMargin alignment:(Alignment)alignment textData:(unsigned char*)textData textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char initial[] = {0x1b, 0x40};
    [commands appendBytes:initial length:2];
    
    unsigned char underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline)
    {
        underlineCommand[2] = 49;
    }
    else
    {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    unsigned char invertColorCommand[] = {0x1b, 0x00};
    if (invertColor)
    {
        invertColorCommand[1] = 0x34;
    }
    else
    {
        invertColorCommand[1] = 0x35;
    }
    [commands appendBytes:invertColorCommand length:2];
    
    unsigned char emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized)
    {
        emphasizedPrinting[1] = 69;
    }
    else
    {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    unsigned char upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline)
    {
        upperLineCommand[2] = 49;
    }
    else
    {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown)
    {
        unsigned char upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    }
    else
    {
        unsigned char upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    unsigned char characterExpansion[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion[2] = heightExpansion + '0';
    characterExpansion[3] = widthExpansion + '0';
    [commands appendBytes:characterExpansion length:4];
    
    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment)
    {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function prints raw Traditional Chinese text to the print.  It show how the text can be formated.  For example changing its size.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * underline - boolean variable that Tells the printer if should underline the text
 * invertColor - boolean variable that tells the printer if it should invert the text its printing.  All White space will become black and the characters will be left white
 * emphasized - boolean variable that tells the printer if it should emphasize the printed text.  This is sort of like bold but not as dark, but darker then regular characters.
 * upperline - boolean variable that tells the printer if to place a line above the text.  This only supported by new printers.
 * upsideDown - boolean variable that tells the printer if the text should be printed upside-down
 * heightExpansion - This integer tells the printer what multiple the character height should be, this should be from 0 to 5 representing multiples from 1 to 6
 * widthExpansion - This integer tell the printer what multiple the character width should be, this should be from 0 to 5 representing multiples from 1 to 6.
 * leftMargin - The left margin for the text.  Although the max value for this can be 255, the value shouldn't get that high or the text could be pushed off the page.
 * alignment - The alignment of the text. The printers support left, right, and center justification
 * textData - The text to print
 * textDataSize - The amount of text to send to the printer
 */
+ (void)PrintCHTTextWithPortname:(NSString *)portName portSettings:(NSString*)portSettings underline:(bool)underline invertColor:(bool)invertColor emphasized:(bool)emphasized upperline:(bool)upperline upsideDown:(bool)upsideDown heightExpansion:(int)heightExpansion widthExpansion:(int)widthExpansion leftMargin:(unsigned char)leftMargin alignment:(Alignment)alignment textData:(unsigned char*)textData textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char initial[] = {0x1b, 0x40};
    [commands appendBytes:initial length:2];
    
    unsigned char underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline)
    {
        underlineCommand[2] = 49;
    }
    else
    {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    unsigned char invertColorCommand[] = {0x1b, 0x00};
    if (invertColor)
    {
        invertColorCommand[1] = 0x34;
    }
    else
    {
        invertColorCommand[1] = 0x35;
    }
    [commands appendBytes:invertColorCommand length:2];
    
    unsigned char emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized)
    {
        emphasizedPrinting[1] = 69;
    }
    else
    {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    unsigned char upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline)
    {
        upperLineCommand[2] = 49;
    }
    else
    {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown)
    {
        unsigned char upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    }
    else
    {
        unsigned char upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    unsigned char characterExpansion[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion[2] = heightExpansion + '0';
    characterExpansion[3] = widthExpansion + '0';
    [commands appendBytes:characterExpansion length:4];
    
    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment)
    {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

#pragma mark common

/**
 * This function is used to print a uiimage directly to the printer.
 * There are 2 ways a printer can usually print images, one is through raster commands the other is through line mode commands
 * This function uses raster commands to print an image.  Raster is support on the tsp100 and all legacy thermal printers
 * The line mode printing is not supported by the tsp100 so its not used
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * source - the uiimage to convert to star raster data
 * maxWidth - the maximum with the image to print.  This is usually the page with of the printer.  If the image exceeds the maximum width then the image is scaled down.  The ratio is maintained.
 */
+ (void)PrintImageWithPortname:(NSString *)portName portSettings:(NSString*)portSettings imageToPrint:(UIImage*)imageToPrint maxWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable withDrawerKick:(BOOL)drawerKick
{
    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];
    
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    if (drawerKick == YES) {
        [commandsToPrint appendBytes:"\x07"
                              length:sizeof("\x07") - 1];    // KickCashDrawer
    }
    
    [self sendCommand:commandsToPrint portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

+ (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings timeoutMillis:(u_int32_t)timeoutMillis
{
    int commandSize = (int)[commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000;
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Write port timed out"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
    }
}

#pragma mark Sample Receipt (Line)

/**
 * This function print the sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[@"Star Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"123 Star Road\r\nCity, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00"
                   length:sizeof("\x1b\x44\x02\x10\x22\x00") - 1];    // SetHT
    
    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:" \x09 "
                   length:sizeof(" \x09 ") - 1];
    
    [commands appendData:[@"Time:HH:MM PM\r\n------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // SetBold
    
    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // CancelBold
    
    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09"
                   length:sizeof("\x09") - 1];    // HT
    
    [commands appendData:[@"  Description   \x09         Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \x09  PLAIN T-SHIRT\x09         10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300692003 \x09  BLACK DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300651148 \x09  BLUE DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300642980 \x09  STRIPED DRESS\x09         49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300638471 \x09  BLACK BOOTS\x09         35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \x09\x09        156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Tax \x09\x09          0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09\x09\x1b\x69\x01\x01"
                   length:sizeof("\x09\x09\x1b\x69\x01\x01") - 1];    // SetDoubleHW
    
    [commands appendData:[@"$156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // CancelDoubleHW
    
    [commands appendData:[@"------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\x1b\x34Refunds and Exchanges\x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within " "\x1b\x2d\x01" "30 days\x1b\x2d\x00" " with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"And tags attached\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendBytes:"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
                   length:sizeof("\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n") - 1];    // PrintBarcode
    
    [commands appendBytes:"\x1b\x64\x02"
                   length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];    // KickCashDrawer
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function print the sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[@"Star Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"123 Star Road\r\nCity, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendBytes:"\x1b\x44\x02\x1a\x37\x00"
                   length:sizeof("\x1b\x44\x02\x1a\x37\x00") - 1];    // SetHT
    
    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:" \x09 "
                   length:sizeof(" \x09 ") - 1];
    
    [commands appendData:[@"Time:HH:MM PM\r\n" "---------------------------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // SetBold
    
    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // CancelBold
    
    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09"
                   length:sizeof("\x09") - 1];    // HT
    
    [commands appendData:[@" Description   \x09         Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \x09  PLAIN T-SHIRT\x09         10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300692003 \x09  BLACK DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300651148 \x09  BLUE DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300642980 \x09  STRIPED DRESS\x09         49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300638471 \x09  BLACK BOOTS\x09         35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \x09\x09        156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Tax \x09\x09          0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"---------------------------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09\x09\x1b\x69\x01\x01"
                   length:sizeof("\x09\x09\x1b\x69\x01\x01") - 1];    // SetDoubleHW
    
    [commands appendData:[@"$156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // CancelDoubleHW
    
    [commands appendData:[@"---------------------------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\x1b\x34Refunds and Exchanges\x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within " "\x1b\x2d\x01" "30 days\x1b\x2d\x00" " with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"And tags attached\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendBytes:"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
                   length:sizeof("\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n") - 1];    // PrintBarcode
    
    [commands appendBytes:"\x1b\x64\x02"
                   length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];    // KickCashDrawer
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function print the Kanji sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintKanjiSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];    // 初期化
    
    [commands appendBytes:"\x1b\x24\x31"
                   length:sizeof("\x1b\x24\x31") - 1];    // 漢字モード設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
                   length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // 強調印字設定
    
    [commands appendData:[@"スター電機\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x01\x00"
                   length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"修理報告書　兼領収書\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // 強調印字解除
    
    [commands appendData:[@"------------------------------------------------\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    //左揃え設定
    
    [commands appendData:[@"発行日時：YYYY年MM月DD日HH時MM分" "\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"TEL：054-347-XXXX\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"           ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"　お名前：池西　静子　様\n"
                          "　御住所：静岡市清水区七ツ新屋\n"
                          "　　　　　５３６番地\n"
                          "　伝票番号：No.12345-67890\n\n"
                          "　この度は修理をご用命頂き有難うございます。\n"
                          " 今後も故障など発生した場合はお気軽にご連絡ください。\n\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x52\x08" length:sizeof("\x1b\x52\x08") - 1];  //国際文字:日本
    
    [commands appendData:[@"品名／型名　          数量      金額　   備考\n"
                          "------------------------------------------------\n"
                          "制御基板　          　  1      10,000     配達\n"
                          "操作スイッチ            1       3,800     配達\n"
                          "パネル　　          　  1       2,000     配達\n"
                          "技術料　          　　  1      15,000\n"
                          "出張費用　　            1       5,000\n"
                          "------------------------------------------------\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"\n"
                          "                            小計       \\ 35,800\n"
                          "                            内税       \\  1,790\n"
                          "                            合計       \\ 37,590\n\n"
                          "　お問合わせ番号　　12345-67890\n\n\n\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];    // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];    // ドロワオープン
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function print the Kanji sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintKanjiSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];    // Initialization
    
    [commands appendBytes:"\x1b\x24\x31"
                   length:sizeof("\x1b\x24\x31") - 1];    // 漢字モード設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
                   length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // 強調印字設定
    
    [commands appendData:[@"スター電機\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x01\x00"
                   length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"修理報告書　兼領収書\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // 強調印字解除
    
    [commands appendData:[@"---------------------------------------------------------------------\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    //左揃え設定
    
    [commands appendData:[@"発行日時：YYYY年MM月DD日HH時MM分" "\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"TEL：054-347-XXXX\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"           ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"　お名前：池西　静子　様\n"
                          "　御住所：静岡市清水区七ツ新屋\n"
                          "　　　　　５３６番地\n"
                          "　伝票番号：No.12345-67890\n\n"
                          "この度は修理をご用命頂き有難うございます。\n"
                          " 今後も故障など発生した場合はお気軽にご連絡ください。\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x52\x08" length:sizeof("\x1b\x52\x08") - 1];  //国際文字:日本
    
    [commands appendData:[@"品名／型名　                 数量             金額　          備考\n"
                          "---------------------------------------------------------------------\n"
                          "制御基板　　                   1             10,000            配達\n"
                          "操作スイッチ                   1              3,800            配達\n"
                          "パネル　　　                   1              2,000            配達\n"
                          "技術料　　　                   1             15,000\n"
                          "出張費用　　                   1              5,000\n"
                          "---------------------------------------------------------------------\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"\n"
                          "                                                 小計       \\ 35,800\n"
                          "                                                 内税       \\  1,790\n"
                          "                                                 合計       \\ 37,590\n\n"
                          "　お問合わせ番号　　12345-67890\n\n\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];    // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];    // ドロワオープン
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function print the Simplified Chinese sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintCHSSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];            // 初期化
    
    [commands appendBytes:"\x1b\x44\x10\x00"
                   length:sizeof("\x1b\x44\x10\x00") - 1];    // 水平タブ位置設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
                   length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"STAR便利店\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x69\x01\x00"
                   length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"欢迎光临\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"Unit 1906-08, 19/F, Enterprise Square 2,\n"
                          "　3 Sheung Yuet Road, Kowloon Bay, KLN\n"
                          "\n"
                          "Tel : (852) 2795 2335\n"
                          "\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    //左揃え設定
    
    [commands appendData:[@"货品名称   　          数量  　   价格\n"
                          "--------------------------------------------\n"
                          "\n"
                          "罐装可乐\n"
                          "* Coke  \x09         1        7.00\n"
                          "纸包柠檬茶\n"
                          "* Lemon Tea  \x09         2       10.00\n"
                          "热狗\n"
                          "* Hot Dog   \x09         1       10.00\n"
                          "薯片(50克装)\n"
                          "* Potato Chips(50g)\x09      1       11.00\n"
                          "--------------------------------------------\n"
                          "\n"
                          "\x09      总数 :\x09     38.00\n"
                          "\x09      现金 :\x09     38.00\n"
                          "\x09      找赎 :\x09      0.00\n"
                          "\n"
                          "卡号码 Card No.       : 88888888\n"
                          "卡余额 Remaining Val. : 88.00\n"
                          "机号   Device No.     : 1234F1\n"
                          "\n"
                          "\n"
                          "DD/MM/YYYY  HH:MM:SS  交易编号 : 88888\n"
                          "\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendData:[@"收银机 : 001  收银员 : 180\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];        // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];                // ドロワオープン
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function print the Simplified Chinese sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintCHSSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];            // 初期化
    
    [commands appendBytes:"\x1b\x44\x10\x00"
                   length:sizeof("\x1b\x44\x10\x00") - 1];    // 水平タブ位置設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
                   length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"STAR便利店\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x69\x01\x00"
                   length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"欢迎光临\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"Unit 1906-08, 19/F, Enterprise Square 2,\n"
                          "　3 Sheung Yuet Road, Kowloon Bay, KLN\n"
                          "\n"
                          "Tel : (852) 2795 2335\n"
                          "\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    //左揃え設定
    
    [commands appendData:[@"货品名称   　                      数量        　         价格\n"
                          "----------------------------------------------------------------\n"
                          "\n"
                          "罐装可乐\n"
                          "* Coke  \x09                     1                    7.00\n"
                          "纸包柠檬茶\n"
                          "* Lemon Tea  \x09                     2                   10.00\n"
                          "热狗\n"
                          "* Hot Dog   \x09                     1                   10.00\n"
                          "薯片(50克装)\n"
                          "* Potato Chips(50g)\x09                  1                   11.00\n"
                          "----------------------------------------------------------------\n"
                          "\n"
                          "\x09                  总数 :\x09                 38.00\n"
                          "\x09                  现金 :\x09                 38.00\n"
                          "\x09                  找赎 :\x09                  0.00\n"
                          "\n"
                          "卡号码 Card No.                   : 88888888\n"
                          "卡余额 Remaining Val.             : 88.00\n"
                          "机号   Device No.                 : 1234F1\n"
                          "\n"
                          "\n"
                          "DD/MM/YYYY  HH:MM:SS\x09        交易编号 : 88888\n"
                          "\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendData:[@"收银机 : 001  收银员 : 180\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];        // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];                // ドロワオープン
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

/**
 * This function print the Traditional Chinese sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintCHTSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];            // 初期化
    
    [commands appendBytes:"\x1b\x44\x10\x00"
                   length:sizeof("\x1b\x44\x10\x00") - 1];    // 水平タブ位置設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
                   length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"Star Micronics\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"--------------------------------------------\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x69\x01\x01"
                   length:sizeof("\x1b\x69\x01\x01") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"電子發票證明聯\n"
                          "103年01-02月\n"
                          "EV-99999999\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"2014/01/15 13:00\n"
                          "隨機碼 : 9999    總計 : 999\n"
                          "賣方 : 99999999\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    //1D barcode example
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];
    [commands appendBytes:"\x1b\x62\x34\x31\x32\x50"
                   length:sizeof("\x1b\x62\x34\x31\x32\x50") - 1];
    
    [commands appendBytes:"999999999\x1e\r\n"
                   length:sizeof("999999999\x1e\r\n") - 1];
    
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    //QR Code
    [commands appendBytes:"\x1b\x1d\x79\x53\x30\x02"
                   length:sizeof("\x1b\x1d\x79\x53\x30\x02") - 1];            //QRコードのモデル設定
    [commands appendBytes:"\x1b\x1d\x79\x53\x31\x02"
                   length:sizeof("\x1b\x1d\x79\x53\x31\x02") - 1];            //QRコードの誤り訂正レベルの設定
    [commands appendBytes:"\x1b\x1d\x79\x53\x32\x05"
                   length:sizeof("\x1b\x1d\x79\x53\x32\x05") - 1];            //QRコードのセルサイズの設定
    [commands appendBytes:"\x1b\x1d\x79\x44\x31\x00\x23\x00"
                   length:sizeof("\x1b\x1d\x79\x44\x31\x00\x23\x00") - 1];    //QRコードデータの設定(自動設定)
    
    [commands appendBytes:"http://www.star-m.jp/eng/index.html"
                   length:sizeof("http://www.star-m.jp/eng/index.html") - 1];
    
    [commands appendBytes:"\x1b\x1d\x79\x50\x0a"
                   length:sizeof("\x1b\x1d\x79\x50\x0a") - 1];                //QRコード印字
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"商品退換請持本聯及銷貨明細表。\n"
                          "9999999-9999999 999999-999999 9999\n\n\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendData:[@"銷貨明細表 　(銷售)\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x32"
                   length:sizeof("\x1b\x1d\x61\x32") - 1];    // 右揃え設定
    
    [commands appendData:[@"2014-01-15 13:00:02\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"\n"
                          "烏龍袋茶2g20入  \x09           55 x2 110TX\n"
                          "茉莉烏龍茶2g20入  \x09         55 x2 110TX\n"
                          "天仁觀音茶2g*20   \x09         55 x2 110TX\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"      小　 計 :\x09             330\n"
                          "      總   計 :\x09             330\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"--------------------------------------------\n"
                          "現 金\x09             400\n"
                          "      找　 零 :\x09              70\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@" 101 發票金額 :\x09             330\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"2014-01-15 13:00\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    
    //1D barcode example
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];
    [commands appendBytes:"\x1b\x62\x34\x31\x32\x50"
                   length:sizeof("\x1b\x62\x34\x31\x32\x50") - 1];
    
    [commands appendBytes:"999999999\x1e\r\n"
                   length:sizeof("999999999\x1e\r\n") - 1];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"商品退換、贈品及停車兌換請持本聯。\n"
                          "9999999-9999999 999999-999999 9999\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];        // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];                // ドロワオープン
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
}

#pragma mark Sample Receipt (Raster)

+ (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width
{
    //NSString *fontName = @"Courier";
    
    //double fontSize = 12.0;
    
    //fontSize *= 2;
    
    //UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    CGSize size = CGSizeMake(width, 10000);
    CGSize messuredSize = [string sizeWithFont:font constrainedToSize:size];
    
    if ([UIScreen.mainScreen respondsToSelector:@selector(scale)]) {
        if (UIScreen.mainScreen.scale == 2.0) {
            UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
        } else {
            UIGraphicsBeginImageContext(messuredSize);
        }
    } else {
        UIGraphicsBeginImageContext(messuredSize);
    }
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width + 1, messuredSize.height + 1);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    [string drawInRect:rect withFont:font];
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageToPrint;
}


/**
 * This function print the Raster sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSString *textToPrint = @"        Star Clothing Boutique\r\n"
    "             123 Star Road\r\n"
    "           City, State 12345\r\n"
    "\r\n"
    "Date: MM/DD/YYYY         Time:HH:MM PM\r\n"
    "--------------------------------------\r\n"
    "SALE\r\n"
    "SKU            Description       Total\r\n"
    "300678566      PLAIN T-SHIRT     10.99\n"
    "300692003      BLACK DENIM       29.99\n"
    "300651148      BLUE DENIM        29.99\n"
    "300642980      STRIPED DRESS     49.99\n"
    "30063847       BLACK BOOTS       35.99\n"
    "\n"
    "Subtotal                        156.95\r\n"
    "Tax                               0.00\r\n"
    "--------------------------------------\r\n"
    "Total                          $156.95\r\n"
    "--------------------------------------\r\n"
    "\r\n"
    "Charge\r\n159.95\r\n"
    "Visa XXXX-XXXX-XXXX-0123\r\n"
    "Refunds and Exchanges\r\n"
    "Within 30 days with receipt\r\n"
    "And tags attached\r\n";
    
    CGFloat width = 576;
    UIFont *font = [UIFont fontWithName:@"Courier" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSString *textToPrint = @"                   Star Clothing Boutique\r\n"
    "                        123 Star Road\r\n"
    "                      City, State 12345\r\n"
    "\r\n"
    "Date: MM/DD/YYYY                            Time:HH:MM PM\r\n"
    "---------------------------------------------------------\r\n"
    "SALE\r\n"
    "SKU                     Description                 Total\r\n"
    "300678566               PLAIN T-SHIRT               10.99\n"
    "300692003               BLACK DENIM                 29.99\n"
    "300651148               BLUE DENIM                  29.99\n"
    "300642980               STRIPED DRESS               49.99\n"
    "300638471               BLACK BOOTS                 35.99\n"
    "\n"
    "Subtotal                                           156.95\r\n"
    "Tax                                                  0.00\r\n"
    "---------------------------------------------------------\r\n"
    "Total                                             $156.95\r\n"
    "---------------------------------------------------------\r\n"
    "\r\n"
    "Charge\r\n159.95\r\n"
    "Visa XXXX-XXXX-XXXX-0123\r\n"
    "Refunds and Exchanges\r\n"
    "Within 30 days with receipt\r\n"
    "And tags attached\r\n";
    
    CGFloat width = 832;
    UIFont *font = [UIFont fontWithName:@"Courier" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster Kanji sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterKanjiSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    char *sjisText = "　　　　　　　　　　スター電機\n"
    "　　　　　　　　修理報告書　兼領収書\n"
    "------------------------------------------------------------------------\r\n"
    "発行日時：YYYY年MM月DD日HH時MM分\n"
    "TEL：054-347-XXXX\n\n"
    "　　　　　ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n"
    "　お名前：池西　静子　様\n"
    "　御住所：静岡市清水区七ツ新屋\n"
    "　　　　　５３６番地\n"
    "　伝票番号：No.12345-67890\n\n"
    "　この度は修理をご用命頂き有難うございます。\n"
    " 今後も故障など発生した場合はお気軽にご連絡ください。\n"
    "\n"
    "品名／型名　　　　数量　　　金額　　　　　備考\n"
    "------------------------------------------------------------------------\r\n"
    "制御基板　　　　　　１　１０，０００　　　配達\n"
    "操作スイッチ　　　　１　　３，８００　　　配達\n"
    "パネル　　　　　　　１　　２，０００　　　配達\n"
    "技術料　　　　　　　１　１５，０００\n"
    "出張費用　　　　　　１　　５，０００\n"
    "------------------------------------------------------------------------\r\n"
    "\n"
    "　　　　　　　　　　　　　小計　¥ ３５，８００\n"
    "　　　　　　　　　　　　　内税　¥ 　１，７９０\n"
    "　　　　　　　　　　　　　合計　¥ ３７，５９０\n"
    "\n"
    "　お問合わせ番号　　12345-67890\n\n";
    
    NSString *textToPrint = [NSString stringWithCString:sjisText encoding:NSUTF8StringEncoding];
    
    CGFloat width = 576;
    UIFont *font = [UIFont fontWithName:@"STHeitiJ-Light" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster Kanji sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterKanjiSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    char *sjisText = "　　　　　　　　　　　　　　　スター電機\n"
    "　　　　　　　　　　　　　修理報告書　兼領収書\n"
    "--------------------------------------------------------------------------------------------------------\r\n"
    "発行日時：YYYY年MM月DD日HH時MM分\n"
    "TEL：054-347-XXXX\n\n"
    "　　　　　ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n"
    "　お名前：池西　静子　様\n"
    "　御住所：静岡市清水区七ツ新屋\n"
    "　　　　　５３６番地\n"
    "　伝票番号：No.12345-67890\n\n"
    "　この度は修理をご用命頂き有難うございます。\n"
    " 今後も故障など発生した場合はお気軽にご連絡ください。\n"
    "\n"
    "品名／型名　　　　　　　　　数量　　　　　　金額　　　　　　　　備考\n"
    "--------------------------------------------------------------------------------------------------------\r\n"
    "制御基板　　　　　　　　　　　１　　　　１０，０００　　　　　　配達\n"
    "操作スイッチ　　　　　　　　　１　　　　　３，８００　　　　　　配達\n"
    "パネル　　　　　　　　　　　　１　　　　　２，０００　　　　　　配達\n"
    "技術料　　　　　　　　　　　　１　　　　１５，０００\n"
    "出張費用　　　　　　　　　　　１　　　　　５，０００\n"
    "--------------------------------------------------------------------------------------------------------\r\n"
    "\n"
    "　　　　　　　　　　　　　　　　　　　　　　　　小計　¥ ３５，８００\n"
    "　　　　　　　　　　　　　　　　　　　　　　　　内税　¥ 　１，７９０\n"
    "　　　　　　　　　　　　　　　　　　　　　　　　合計　¥ ３７，５９０\n"
    "\n"
    "　お問合わせ番号　　12345-67890\n\n";
    
    NSString *textToPrint = [NSString stringWithCString:sjisText encoding:NSUTF8StringEncoding];
    
    CGFloat width = 832;
    UIFont *font = [UIFont fontWithName:@"STHeitiJ-Light" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster Simplified Chainese sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterCHSSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    char *gb2312Text = "　　　　　　  　　STAR便利店\n"
    "                欢迎光临\n"
    "\n"
    "Unit 1906-08,19/F,Enterprise Square 2,\n"
    "  3 Sheung Yuet Road, Kowloon Bay, KLN\n"
    "\n"
    "Tel: (852) 2795 2335\n"
    "\n"
    "货品名称                 数量   　  价格\n"
    "---------------------------------------\r\n"
    "罐装可乐\n"
    "* Coke                   1        7.00\n"
    "纸包柠檬茶\n"
    "* Lemon Tea              2       10.00\n"
    "热狗\n"
    "* Hot Dog                1       10.00\n"
    "薯片(50克装)\n"
    "* Potato Chips(50g)      1       11.00\n"
    "---------------------------------------\r\n"
    "\n"
    "                        总　数 :  38.00\n"
    "                        现　金 :  38.00\n"
    "                        找　赎 :   0.00\n"
    "\n"
    "卡号码 Card No.        :       88888888\n"
    "卡余额 Remaining Val.  :       88.00\n"
    "机号　 Device No.      :       1234F1\n"
    "\n"
    "DD/MM/YYYY   HH:MM:SS   交易编号: 88888\n"
    "\n"
    "          收银机:001  收银员:180\n";
    
    NSString *textToPrint = [NSString stringWithCString:gb2312Text encoding:NSUTF8StringEncoding];
    
    CGFloat width = 576;
    
    UIFont *font = [UIFont fontWithName:@"Courier" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster Simplified Chainese sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterCHSSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    char *gb2312Text = "　　　　　　  　　         STAR便利店\n"
    "                          欢迎光临\n"
    "\n"
    "     Unit 1906-08,19/F,Enterprise Square 2,\n"
    "                3 Sheung Yuet Road, Kowloon Bay, KLN\n"
    "\n"
    "Tel: (852) 2795 2335\n"
    "\n"
    "货品名称                               数量          价格\n"
    "---------------------------------------------------------\r\n"
    "罐装可乐\n"
    "* Coke                                 1            7.00\n"
    "纸包柠檬茶\n"
    "* Lemon Tea                            2           10.00\n"
    "热狗\n"
    "* Hot Dog                              1           10.00\n"
    "薯片(50克装)\n"
    "* Potato Chips(50g)                    1           11.00\n"
    "---------------------------------------------------------\r\n"
    "\n"
    "                                          总　数 :  38.00\n"
    "                                          现　金 :  38.00\n"
    "                                          找　赎 :   0.00\n"
    "\n"
    "卡号码 Card No.        :       88888888\n"
    "卡余额 Remaining Val.  :       88.00\n"
    "机号　 Device No.      :       1234F1\n"
    "\n"
    "DD/MM/YYYY              HH:MM:SS          交易编号: 88888\n"
    "\n"
    "                   收银机:001  收银员:180\n";
    
    NSString *textToPrint = [NSString stringWithCString:gb2312Text encoding:NSUTF8StringEncoding];
    
    CGFloat width = 832;
    
    UIFont *font = [UIFont fontWithName:@"Courier" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster Traditional Chainese sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterCHTSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    char *gig5Text = "　 　　　  　　Star Micronics\n"
    "---------------------------------------\r\n"
    "              電子發票證明聯\n"
    "              103年01-02月\n"
    "              EV-99999999\n"
    "2014/01/15 13:00\n"
    "隨機碼 : 9999      總計 : 999\n"
    "賣　方 : 99999999\n"
    "\n"
    "商品退換請持本聯及銷貨明細表。\n"
    "9999999-9999999 999999-999999 9999\n"
    "\n"
    "\n"
    "         銷貨明細表 　(銷售)\n"
    "                    2014-01-15 13:00:02\n"
    "\n"
    "烏龍袋茶2g20入　         55 x2    110TX\n"
    "茉莉烏龍茶2g20入         55 x2    110TX\n"
    "天仁觀音茶2g*20　        55 x2    110TX\n"
    "     小　　計 :　　        330\n"
    "     總　　計 :　　        330\n"
    "---------------------------------------\r\n"
    "現　金　　　               400\n"
    "     找　　零 :　　         70\n"
    " 101 發票金額 :　　        330\n"
    "2014-01-15 13:00\n"
    "\n"
    "商品退換、贈品及停車兌換請持本聯。\n"
    "9999999-9999999 999999-999999 9999\n";
    
    NSString *textToPrint = [NSString stringWithCString:gig5Text encoding:NSUTF8StringEncoding];
    
    CGFloat width = 576;
    UIFont *font = [UIFont fontWithName:@"Courier" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

/**
 * This function print the Raster Traditional Chainese sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterCHTSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    char *gig5Text = "　 　　　  　  　       Star Micronics\n"
    "---------------------------------------------------------\r\n"
    "                       電子發票證明聯\n"
    "                       103年01-02月\n"
    "                       EV-99999999\n"
    "2014/01/15 13:00\n"
    "隨機碼 : 9999      總計 : 999\n"
    "賣　方 : 99999999\n"
    "\n"
    "商品退換請持本聯及銷貨明細表。\n"
    "9999999-9999999 999999-999999 9999\n"
    "\n"
    "\n"
    "                      銷貨明細表 　(銷售)\n"
    "                                      2014-01-15 13:00:02\n"
    "\n"
    "烏龍袋茶2g20入　                   55 x2        110TX\n"
    "茉莉烏龍茶2g20入                   55 x2        110TX\n"
    "天仁觀音茶2g*20　                  55 x2        110TX\n"
    "     小　　計 :　　                  330\n"
    "     總　　計 :　　                  330\n"
    "---------------------------------------------------------\r\n"
    "現　金　　　                         400\n"
    "     找　　零 :　　                   70\n"
    " 101 發票金額 :　　                  330\n"
    "2014-01-15 13:00\n"
    "\n"
    "商品退換、贈品及停車兌換請持本聯。\n"
    "9999999-9999999 999999-999999 9999\n";
    
    NSString *textToPrint = [NSString stringWithCString:gig5Text encoding:NSUTF8StringEncoding];
    
    CGFloat width = 832;
    
    UIFont *font = [UIFont fontWithName:@"Courier" size:(12.0 * 2)];
    
    UIImage *imageToPrint = [self imageWithString:textToPrint font:font width:width];
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES withDrawerKick:YES];
}

#pragma mark Sample Receipt (Line) - without drawer kick

/**
 * This function print the sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintSampleReceipt3InchWithoutDrawerKickWithPortname:(NSString *)portName portSettings:(NSString *)portSettings errorMessage:(NSMutableString *)message
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[@"Star Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"123 Star Road\r\nCity, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00"
                   length:sizeof("\x1b\x44\x02\x10\x22\x00") - 1];    // SetHT
    
    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:" \x09 "
                   length:sizeof(" \x09 ") - 1];
    
    [commands appendData:[@"Time:HH:MM PM\r\n------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // SetBold
    
    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // CancelBold
    
    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09"
                   length:sizeof("\x09") - 1];    // HT
    
    [commands appendData:[@"  Description   \x09         Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \x09  PLAIN T-SHIRT\x09         10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300692003 \x09  BLACK DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300651148 \x09  BLUE DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300642980 \x09  STRIPED DRESS\x09         49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300638471 \x09  BLACK BOOTS\x09         35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \x09\x09        156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Tax \x09\x09          0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09\x09\x1b\x69\x01\x01"
                   length:sizeof("\x09\x09\x1b\x69\x01\x01") - 1];    // SetDoubleHW
    
    [commands appendData:[@"$156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // CancelDoubleHW
    
    [commands appendData:[@"------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\x1b\x34Refunds and Exchanges\x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within " "\x1b\x2d\x01" "30 days\x1b\x2d\x00" " with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"And tags attached\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendBytes:"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
                   length:sizeof("\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n") - 1];    // PrintBarcode
    
    [commands appendBytes:"\x1b\x64\x02"
                   length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000 errorMessage:message];
    
}

/**
 * This function print the sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintSampleReceipt4InchWithoutDrawerKickWithPortname:(NSString *)portName portSettings:(NSString *)portSettings errorMessage:(NSMutableString *)message
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[@"Star Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"123 Star Road\r\nCity, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
                   length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendBytes:"\x1b\x44\x02\x1a\x37\x00"
                   length:sizeof("\x1b\x44\x02\x1a\x37\x00") - 1];    // SetHT
    
    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:" \x09 "
                   length:sizeof(" \x09 ") - 1];
    
    [commands appendData:[@"Time:HH:MM PM\r\n" "---------------------------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // SetBold
    
    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // CancelBold
    
    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09"
                   length:sizeof("\x09") - 1];    // HT
    
    [commands appendData:[@" Description   \x09         Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \x09  PLAIN T-SHIRT\x09         10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300692003 \x09  BLACK DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300651148 \x09  BLUE DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300642980 \x09  STRIPED DRESS\x09         49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300638471 \x09  BLACK BOOTS\x09         35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \x09\x09        156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Tax \x09\x09          0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"---------------------------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09\x09\x1b\x69\x01\x01"
                   length:sizeof("\x09\x09\x1b\x69\x01\x01") - 1];    // SetDoubleHW
    
    [commands appendData:[@"$156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // CancelDoubleHW
    
    [commands appendData:[@"---------------------------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\x1b\x34Refunds and Exchanges\x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within " "\x1b\x2d\x01" "30 days\x1b\x2d\x00" " with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"And tags attached\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendBytes:"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
                   length:sizeof("\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n") - 1];    // PrintBarcode
    
    [commands appendBytes:"\x1b\x64\x02"
                   length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000 errorMessage:message];
    
}

+ (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings
      timeoutMillis:(u_int32_t)timeoutMillis errorMessage:(NSMutableString *)message
{
    int commandSize = (int)[commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil)
        {
            [message appendString:@"Fail to Open Port"];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            [message appendString:@"Printer is offline"];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec) {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize) {
            [message appendString:@"Write port timed out"];
            return;
        }
        
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            [message appendString:@"Printer is offline"];
            return;
        }
    }
    @catch (PortException *exception)
    {
        [message appendString:@"Write port timed out"];
    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
    }
}

#pragma mark Bluetooth Setting
+ (SMBluetoothManager *)loadBluetoothSetting:(NSString *)portName portSettings:(NSString *)portSettings {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    
    if ([portName rangeOfString:@"BT:" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 3)].location == NSNotFound) {
        alert.message = @"This function is available via the bluetooth interface only.";
        [alert show];
        return nil;
    }
    
    SMDeviceType deviceType;
    if ([portSettings rangeOfString:@"MINI" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        deviceType = SMDeviceTypePortablePrinter;
    } else {
        deviceType = SMDeviceTypeDesktopPrinter;
    }
    
    SMBluetoothManager *manager = [[SMBluetoothManager alloc] initWithPortName:portName deviceType:deviceType];
    if (manager == nil) {
        alert.message = @"initWithPortName:deviceType: is failure.";
        [alert show];
        return nil;
    }
    
    if ([manager open] == NO) {
        alert.message = @"open is failure.";
        [alert show];
        return nil;
    }
    
    if ([manager loadSetting] == NO) {
        alert.message = @"loadSetting is failure.";
        [alert show];
        [manager close];
        return nil;
    }
    
    [manager close];
    
    return manager;
}

#pragma mark diconnect bluetooth

+ (void)disconnectPort:(NSString *)portName portSettings:(NSString *)portSettings timeout:(u_int32_t)timeout {
    SMPort *port = [SMPort getPort:portName :portSettings :timeout];
    if (port == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BOOL result = [port disconnect];
    if (result == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Disconnect" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    [SMPort releasePort:port];
}

@end