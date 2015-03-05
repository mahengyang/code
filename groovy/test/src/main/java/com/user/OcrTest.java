package com.user;

import com.asprise.ocr.Ocr;
import java.io.File;

public class OcrTest {

    public static void main(String[] args){
    	Ocr.setUp(); // one time setup
		Ocr ocr = new Ocr(); // create a new OCR engine
		ocr.startEngine("eng", Ocr.SPEED_FASTEST); // English
		String filename1 = "D:\\software\\asprise-ocr-java-5\\img\\test.png";
		String filename2 = "A76H.jpg";
		String filename3 = "asprise.jpg";
		String s = ocr.recognize(
			new File[] {new File(filename2)},
			Ocr.RECOGNIZE_TYPE_ALL, 
			Ocr.OUTPUT_FORMAT_PLAINTEXT,
			0, 
			null);
		System.out.println("Result: " + s);
		ocr.stopEngine();
    }
}