class ContactDetailsController < ApplicationController
  before_action :set_contact_detail, only: %i[ show update destroy ]

  # GET /contact_details
  def index
    @contact_details = ContactDetail.all

    render json: @contact_details
  end

  # GET /contact_details/1
  def show
    render json: @contact_detail
  end

  # POST /contact_details
  def create
    @contact_detail = ContactDetail.new(contact_detail_params)

    if @contact_detail.save
      render json: @contact_detail, status: :created, location: @contact_detail
    else
      render json: @contact_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contact_details/1
  def update
    if @contact_detail.update(contact_detail_params)
      render json: @contact_detail
    else
      render json: @contact_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contact_details/1
  def destroy
    @contact_detail.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_detail
      @contact_detail = ContactDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def contact_detail_params
      params.require(:contact_detail).permit(:email, :u_email, :phone, :alt_phone, :socials, :user_id)
    end
end
