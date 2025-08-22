package compressed;

import compressed.java.JavaImageCompressor;
import lombok.extern.slf4j.Slf4j;

import java.io.File;

@Slf4j
public class Main {

    public static void main(String[] args) {

        if (args.length != 3) {
            log.error("Usage: java -jar <jar-file-name>.jar <source-image-path> <output-image-path> <compression-quality>");
            return;
        }

        String sourceImagePath = args[0];
        String outputImagePath = args[1];
        float compressionQuality;

        try {
            compressionQuality = Float.parseFloat(args[2]);
            if (compressionQuality < 0.0f || compressionQuality > 1.0f) {
                throw new NumberFormatException("Invalid compression quality. Please provide a number between 0.0 and 1.0.");
            }
        } catch (NumberFormatException e) {
            log.error("Invalid compression quality. Please provide a number between 0.0 and 1.0.", e);
            return;
        }

        ImageCompressor imageCompressor = new JavaImageCompressor();
        try {
            log.info("Source: {}, Output: {}, Quality: {}", sourceImagePath, outputImagePath, compressionQuality);
            imageCompressor.compressImage(new File(sourceImagePath), new File(outputImagePath), compressionQuality);
            log.info("Image compression completed successfully.");
        } catch (Exception e) {
            log.error("Error during image compression:", e);
        }
    }
}
