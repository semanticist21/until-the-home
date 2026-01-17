package com.kkomi;

import kr.dogfoot.hwpxlib.reader.HWPXReader;
import kr.dogfoot.hwpxlib.tool.textextractor.TextExtractMethod;
import kr.dogfoot.hwpxlib.tool.textextractor.TextExtractor;
import kr.dogfoot.hwpxlib.object.HWPXFile;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType0Font;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;

/**
 * HWPX to PDF Converter
 *
 * Converts HWPX files to PDF using hwpxlib for text extraction
 * and Apache PDFBox for PDF generation.
 */
public class HwpxToPdfConverter {
    private static final Logger logger = LoggerFactory.getLogger(HwpxToPdfConverter.class);

    // PDF configuration
    private static final float MARGIN = 50;
    private static final float FONT_SIZE = 12;
    private static final float LINE_HEIGHT = FONT_SIZE * 1.5f;
    private static final int MAX_CHARS_PER_LINE = 80;

    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: java -jar hwpx-converter.jar <input.hwpx> <output.pdf>");
            System.exit(1);
        }

        String inputPath = args[0];
        String outputPath = args[1];

        try {
            convertHwpxToPdf(inputPath, outputPath);
            logger.info("Successfully converted {} to {}", inputPath, outputPath);
            System.out.println("Conversion successful: " + outputPath);
        } catch (Exception e) {
            logger.error("Failed to convert {} to PDF", inputPath, e);
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    /**
     * Converts HWPX file to PDF
     *
     * @param inputPath Path to input HWPX file
     * @param outputPath Path to output PDF file
     * @throws IOException If file operations fail
     */
    public static void convertHwpxToPdf(String inputPath, String outputPath) throws IOException {
        logger.info("Starting conversion: {} -> {}", inputPath, outputPath);

        // Step 1: Read HWPX file and extract text
        String extractedText = extractTextFromHwpx(inputPath);
        logger.info("Extracted text length: {} characters", extractedText.length());

        // Step 2: Generate PDF from extracted text
        generatePdfFromText(extractedText, outputPath);
        logger.info("PDF generated successfully");
    }

    /**
     * Extracts text from HWPX file using hwpxlib
     *
     * @param hwpxPath Path to HWPX file
     * @return Extracted text content
     * @throws IOException If reading HWPX file fails
     */
    private static String extractTextFromHwpx(String hwpxPath) throws IOException {
        File hwpxFile = new File(hwpxPath);

        if (!hwpxFile.exists()) {
            throw new IOException("HWPX file not found: " + hwpxPath);
        }

        try {
            // Read HWPX file structure
            HWPXFile hwpxFileObj = HWPXReader.fromFilepath(hwpxPath);

            // Extract text using hwpxlib's TextExtractor
            String extractedText = TextExtractor.extract(
                hwpxFileObj,
                kr.dogfoot.hwpxlib.tool.textextractor.TextExtractMethod.InsertControlTextBetweenParagraphText,
                false,
                new kr.dogfoot.hwpxlib.tool.textextractor.TextMarks()
                    .lineBreakAnd("\n")
                    .paraSeparatorAnd("\n\n")
            );

            if (extractedText == null || extractedText.isEmpty()) {
                logger.warn("No text extracted from HWPX file");
                return "";
            }

            return extractedText;
        } catch (Exception e) {
            throw new IOException("Failed to extract text from HWPX: " + e.getMessage(), e);
        }
    }

    /**
     * Generates PDF file from text content
     *
     * @param text Text content to write to PDF
     * @param pdfPath Output PDF file path
     * @throws IOException If PDF generation fails
     */
    private static void generatePdfFromText(String text, String pdfPath) throws IOException {
        try (PDDocument document = new PDDocument()) {
            PDPage currentPage = new PDPage(PDRectangle.A4);
            document.addPage(currentPage);

            // Load Korean font (Noto Sans KR)
            PDType0Font koreanFont;
            try {
                java.io.InputStream fontStream = HwpxToPdfConverter.class.getResourceAsStream("/NotoSansKR.ttf");
                if (fontStream == null) {
                    throw new IOException("Korean font resource not found");
                }
                koreanFont = PDType0Font.load(document, fontStream);
                logger.info("Loaded Korean font: Noto Sans KR");
            } catch (Exception e) {
                logger.warn("Failed to load Korean font, falling back to Helvetica", e);
                koreanFont = null;
            }

            PDPageContentStream contentStream = new PDPageContentStream(document, currentPage);

            float yPosition = currentPage.getMediaBox().getHeight() - MARGIN;
            float pageWidth = currentPage.getMediaBox().getWidth() - (2 * MARGIN);

            contentStream.beginText();
            contentStream.setFont(koreanFont != null ? koreanFont : PDType1Font.HELVETICA, FONT_SIZE);
            contentStream.newLineAtOffset(MARGIN, yPosition);
            contentStream.setLeading(LINE_HEIGHT);

            // Split text into lines and write to PDF
            String[] lines = text.split("\\r?\\n");

            for (String line : lines) {
                // Handle empty lines
                if (line.trim().isEmpty()) {
                    contentStream.newLine();
                    yPosition -= LINE_HEIGHT;

                    // Check if new page is needed
                    if (yPosition < MARGIN) {
                        contentStream.endText();
                        contentStream.close();

                        currentPage = new PDPage(PDRectangle.A4);
                        document.addPage(currentPage);
                        contentStream = new PDPageContentStream(document, currentPage);

                        yPosition = currentPage.getMediaBox().getHeight() - MARGIN;
                        contentStream.beginText();
                        contentStream.setFont(koreanFont != null ? koreanFont : PDType1Font.HELVETICA, FONT_SIZE);
                        contentStream.newLineAtOffset(MARGIN, yPosition);
                        contentStream.setLeading(LINE_HEIGHT);
                    }
                    continue;
                }

                // Write line (basic implementation - may need improvement for long lines)
                try {
                    contentStream.showText(line);
                    contentStream.newLine();
                    yPosition -= LINE_HEIGHT;

                    // Check if new page is needed
                    if (yPosition < MARGIN) {
                        contentStream.endText();
                        contentStream.close();

                        currentPage = new PDPage(PDRectangle.A4);
                        document.addPage(currentPage);
                        contentStream = new PDPageContentStream(document, currentPage);

                        yPosition = currentPage.getMediaBox().getHeight() - MARGIN;
                        contentStream.beginText();
                        contentStream.setFont(koreanFont != null ? koreanFont : PDType1Font.HELVETICA, FONT_SIZE);
                        contentStream.newLineAtOffset(MARGIN, yPosition);
                        contentStream.setLeading(LINE_HEIGHT);
                    }
                } catch (IllegalArgumentException e) {
                    // If character is not supported by font, replace with placeholder
                    logger.warn("Unsupported character in line, using placeholder: {}", e.getMessage());
                    contentStream.showText("(unsupported characters)");
                    contentStream.newLine();
                    yPosition -= LINE_HEIGHT;
                }
            }

            contentStream.endText();
            contentStream.close();

            // Save PDF to file
            document.save(pdfPath);
            logger.info("PDF saved to: {}", pdfPath);
        }
    }
}
