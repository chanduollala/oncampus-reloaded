class InternshipDocumentsController < ApplicationController
  before_action :set_internship_document, only: %i[ show update destroy ]

  # GET /internship_documents
  def index
    @internship_documents = InternshipDocument.all

    render json: @internship_documents
  end

  # GET /internship_documents/1
  def show
    render json: @internship_document
  end

  # POST /internship_documents
  def create
    @internship_document = InternshipDocument.new(internship_document_params)

    if @internship_document.save
      render json: @internship_document, status: :created, location: @internship_document
    else
      render json: @internship_document.errors, status: :unprocessable_entity
    end
  end

  def upload_doc
    @internship_id = params[:id]
    drive_file_id = Service::GoogleSpreadsheetsHelper.upload_internship_document(params[:file], 1, params[:type])
    if drive_file_id

      doc = InternshipDocument.find_by(title: File.basename(params[:file].original_filename, ".*"))
      unless doc
        doc = InternshipDocument.new
      end
      doc.internship_id = @internship_id
      doc.document_link = drive_file_id
      doc.is_verified = false
      doc.title = params[:file].original_filename

      if doc.save
        Internship.find(@internship_id).update(noc:false)
        render json: {id: doc.id}, status: :created
      else
        render json: doc.errors, status: :unprocessable_entity
      end
    else
      render json: {}, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /internship_documents/1
  def update
    if @internship_document.update(internship_document_params)
      render json: @internship_document
    else
      render json: @internship_document.errors, status: :unprocessable_entity
    end
  end


  def get_thumbnail
    redirect_to Service::GoogleSpreadsheetsHelper.fetch_thumbnail(params[:file_id]), allow_other_host: true
  end

  # DELETE /internship_documents/1
  def destroy
    @internship_document.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internship_document
      @internship_document = InternshipDocument.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def internship_document_params
      params.require(:internship_document).permit(:user_id, :title, :document_link, :is_verified)
    end
end
