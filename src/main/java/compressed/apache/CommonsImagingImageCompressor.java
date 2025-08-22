package compressed.apache;


import compressed.ImageCompressor;
import org.apache.commons.imaging.ImageFormat;
import org.apache.commons.imaging.Imaging;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class CommonsImagingImageCompressor implements ImageCompressor {

    @Override
    public void compressImage(File input, File output, float quality) throws IOException {
        // 获取图片的格式
        ImageFormat imageFormat = Imaging.guessFormat(input);
        BufferedImage bufferedImage = Imaging.getBufferedImage(input);

    }
}
