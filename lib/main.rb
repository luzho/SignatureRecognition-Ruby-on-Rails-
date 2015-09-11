#Carlos Dominguez
#Email: carlosa.dominguezf@gmail.com
#Get signatures from document
#Receives 2 parameter, which should be the path to the file you want to edit and the number of boxes in the document 

require 'opencv'
include OpenCV

class Main
	#Save image
	def self.saveImage(image,directory)
		image.save_image(directory)
	end
	#Remove Background
	def self.removeBackground(image)
		alpha=0.5
		beta=1-alpha
		tmp = image.BGR2GRAY
		a = tmp.adaptive_threshold(255,threshold_type: CV_THRESH_BINARY_INV,adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C, block_size: 11, param1: 2)
		b,g,r = image.split
		b = b.adaptive_threshold(255,threshold_type: CV_THRESH_BINARY,adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C, block_size: 11, param1: 2)
		g = g.adaptive_threshold(255,threshold_type: CV_THRESH_BINARY,adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C, block_size: 11, param1: 2)
		r = r.adaptive_threshold(255,threshold_type: CV_THRESH_BINARY,adaptive_method: CV_ADAPTIVE_THRESH_GAUSSIAN_C, block_size: 11, param1: 2)
		dst=CvMat.merge(b,g,r,a)
		dst2= dst
		dst2=dst2.smooth(CV_BLUR,1,0)
		dst=dst.smooth(CV_BLUR,3,1)
		dst=CvMat.add_weighted(dst,alpha,dst2,beta,0.0)
		return dst
	end

	#Show image
	def self.showImage(image)
		window = GUI::Window.new('Display window') # Create a window for display.
		window.show(image) # Show our image inside it.
		GUI::wait_key # Wait for a keystroke in the window.
	end

	#Convert file to whatever type to another type, preferably images
	def self.convert(fileIn,fileOut)
		IO.popen("convert #{fileIn} #{fileOut}"){|f| puts f.gets}
		IO.popen("rm #{fileIn}")

	end

	def self.getSignatures(filename,n)
		signatures= Array.new
		m=Integer(n)
		image = nil
		size=CvSize.new(1024,768)
		image2 = nil
		#Load file	
		begin
			puts "#{filename}"
		  	image = CvMat.load(filename, CV_LOAD_IMAGE_COLOR) # Read the file.
		  	image=image.resize(size,interpolation = CV_INTER_LINEAR)
		rescue
		  	puts 'Could not open or find the image.'
		  	exit
		end

		grayImage=image.BGR2GRAY
		mean = grayImage.adaptive_threshold(255,threshold_type: CV_THRESH_BINARY,adaptive_method: CV_ADAPTIVE_THRESH_MEAN_C, block_size: 75, param1: 10)
		kernel=IplConvKernel.new(3,3,1,1,CV_SHAPE_CROSS)
		erosion=mean.erode(element=kernel,iteration = 1)
		canny = erosion.canny(50, 150)
		contours=canny.find_contours(:mode => CV_RETR_LIST, :method => CV_CHAIN_APPROX_SIMPLE)

		box = nil
		k = 0
		while contours && k< m
	      	
			if !contours.hole? && contours.contour_area > 60000
				box = contours.bounding_rect			
				crop = image.sub_rect(box.x+10,box.y+8,box.width-18,box.height-17)
				crop=removeBackground(crop)
				signatures << crop
				k+=1
				
			end
			contours = contours.h_next
		end
		return signatures
	end
end
	

