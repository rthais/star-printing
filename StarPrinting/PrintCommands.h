//
//  PrinterCommands.h
//  StarPrinting
//
//  Created by Matthew Newberry on 4/11/13.
//  OpenTable
//

typedef enum PrinterBarcodeType
{
    PrinterBarcodeTypeUPCE,
    PrinterBarcodeTypeUPCA,
    PrinterBarcodeTypeEAN8,
    PrinterBarcodeTypeEAN13,
    PrinterBarcodeTypeCode39,
    PrinterBarcodeTypeITF,
    PrinterBarcodeTypeCode128,
    PrinterBarcodeTypeCode93,
    PrinterBarcodeTypeNW7
} PrinterBarcodeType;

#define kPrinterCMD_Tab                 @""
#define kPrinterCMD_Newline             @""

// Alignment
#define kPrinterCMD_AlignCenter         @""
#define kPrinterCMD_AlignLeft           @""
#define kPrinterCMD_AlignRight          @""
#define kPrinterCMD_HorizTab            @""


// Text Formatting
#define kPrinterCMD_StartBold           @""
#define kPrinterCMD_EndBold             @""
#define kPrinterCMD_StartUnderline      @""
#define kPrinterCMD_EndUnderline        @""
#define kPrinterCMD_StartUpperline      @""
#define kPrinterCMD_EndUpperline        @""

#define kPrinterCMD_StartDoubleHW       @""
#define kPrinterCMD_EndDoubleHW         @""

#define kPrinterCMD_StartInvertColor    @""
#define kPrinterCMD_EndInvertColor      @""


// Cutting
#define kPrinterCMD_CutFull             @""
#define kPrinterCMD_CutPartial          @""


// Barcode
#define kPrinterCMD_StartBarcode        @"" "12ab34cd56\r\n"
#define kPrinterCMD_EndBarcode          @""