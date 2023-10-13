class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show update destroy update_logo get_logo ]

  # GET /companies
  def index
    if params[:search_term]
      @companies = Company.where(
        'company_name LIKE :term',
        term: "%#{params[:search_term]}%"
      )
    else
      @companies = Company.limit(5)
    end
    render json: @companies, only: [:id,:company_name]
  end


  # GET /companies/1
  def show
    render json: @company
  end

  def get_logo
    if @company.logo.attached?
      redirect_to url_for(@company.logo)
    else
      render json: {error: @company.errors}, status: :not_found
    end
  end

  def update_logo
    @company.logo.attach(params[:logo])
    if @company.logo
      render json: {status: "suuccess"}, status: :ok
    end
  end

  # POST /companies
  def create
    @company = Company.new(company_params)

    if @company.save
      render json: @company, status: :created, location: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.require(:company).permit(:company_name, :address, :contact, :passkey, :des)
    end
end
