package compressed;

import java.io.File;
import java.io.IOException;

public interface ImageCompressor {

    /**
     * Compress an image
     *
     * @param input   input image
     * @param output  output image
     * @param quality image quality (0.0f - 1.0f)
     */
    void compressImage(File input, File output, float quality) throws IOException;
}
