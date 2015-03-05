package com.user

import com.asprise.ocr.Ocr

class Ocr {
    def static main(args) {
    	Ocr ocr = new Ocr()
    	println '==============='
    	println Ocr.metaClass.methods
    	println '==============='
    	Ocr.metaClass.methods.grep{
    		it.static
    	}.each{
    		println it.name
    	}
    	println '==============='
    	Ocr.setUp()
    	ocr.startEngine("eng", Ocr.SPEED_FASTEST)
    	def File[] files = [new File('test.png')]
    	String s = ocr.recognize(
	    	files,
	    	Ocr.RECOGNIZE_TYPE_ALL, 
	    	Ocr.OUTPUT_FORMAT_PLAINTEXT)
    	println s
    	ocr.stopEngine
    }
}