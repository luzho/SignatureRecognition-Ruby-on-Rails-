require_dependency("main.rb", message = "No such file to load -- %s")
class DocumentsController < ApplicationController	
	def index
    	@documents= Document.all
  	end

  	def show
    	@document = Document.find(params[:id])
  	end

  	def new
    	@document = Document.new
  	end

  	def create
	    @document = Document.new(document_params)
	    if @document.save
	    	flash[:notice] = "Successfully created document."
	    	image="/home/carlos/Projects/signatureRecognition/public"+@document.image_url
	    	sig=Main.getSignatures(image,params[:number])
	    	i = 0
	    	for signature in sig
	    		filename="#{@document.id}_#{@document.name}_#{i}.png"
	    		Main.saveImage(signature,filename)
	    		i += 1
	    		@signature=Signature.new(name:"#{@document.name}1",document_id:"#{@document.id}")
	    		@signature.image=File.open(filename)
	    		@signature.save
	    		puts "#{filename}"
	    		IO.popen("rm #{filename}")
	    	end
	    	redirect_to @document
	    else
	    	render :action => 'new'
	    end
	end

	def edit
    	@document = Document.find(params[:id])
  	end

  	def update
	    @document = Document.find(params[:id])
	    if @document.update_attributes(params[:document])
	      	flash[:notice] = "Successfully updated gallery."
	      	redirect_to document_url
	    else
	      	render :action => 'edit'
	    end
  	end

  	def destroy
	    @document = Document.find(params[:id])
	    @document.destroy
	    flash[:notice] = "Successfully destroyed gallery."
	    redirect_to documents_url
  	end

  	def document_params
      	params.require(:document).permit(:name, :image, :remote_img_url)
    end

end