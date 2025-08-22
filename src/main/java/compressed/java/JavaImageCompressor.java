package compressed.java;

import compressed.ImageCompressor;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.Iterator;

public class JavaImageCompressor implements ImageCompressor {
    @Override
    public void compressImage(File input, File output, float quality) throws IOException {
        String imageName = input.getName();
        String imageFormat = imageName.substring(imageName.lastIndexOf(".") + 1);
        if (!imageFormat.equalsIgnoreCase("jpg") && !imageFormat.equalsIgnoreCase("jpeg") && !imageFormat.equalsIgnoreCase("tiff")) {
            throw new IllegalArgumentException("Unsupported image format: " + imageFormat);
        }

        BufferedImage image = ImageIO.read(input);
        if (image == null) {
            throw new IOException("Unsupported image format or corrupted file: " + input.getName());
        }

        Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName(imageFormat);
        if (!writers.hasNext()) {
            throw new IOException("No suitable ImageWriter found for format: " + imageFormat);
        }

        try (OutputStream os = Files.newOutputStream(output.toPath());
             ImageOutputStream ios = ImageIO.createImageOutputStream(os)) {

            ImageWriter writer = writers.next();
            writer.setOutput(ios);

            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(quality);

            writer.write(null, new IIOImage(image, null, null), param);

            writer.dispose();
        }
    }
}
