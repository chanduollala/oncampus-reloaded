class RecruitmentsController < ApplicationController
  before_action :set_recruitment, only: %i[ show update destroy get_status ]
  before_action :authorize_collegeadmin_request, only: %i[ create update get_status]
  before_action :authorize_user_request, only: %i[ index show ]

  # GET /recruitments
  def index
    @recruitments = Recruitment.where(college_id: @user.college.id)


    render json: @recruitments, only: [:id, :role, :ctc, :location,:last_date, :role_type,:completed, :eligibility],
           include: [company: {only: [:company_name, :id]}]
  end



  # GET /recruitments/1
  def show
    @recruitment.recruitment_updates = @recruitment.recruitment_updates.order(created_at: :asc)

    render json: @recruitment,
           only: [:id, :role, :ctc, :location,:last_date, :role_type,:completed, :eligibility, :company_id],
           include: [company: {only: [:id, :company_name]},
                     recruitment_updates:{
                       only: [:title, :description, :start, :end, :link1, :link2, :index],
                     }]
  end

  # POST /recruitments
  def create
    @recruitment = Recruitment.new(recruitment_params)

    @recruitment.college = @college_admin.college

    if @recruitment.save
      render json: @recruitment, only: [:id], status: :created
    else
      render json: @recruitment.errors, status: :unprocessable_entity
    end
  end

  # def get_status
  #   if @recruitment
  #     render json: {completed: @recruitment.completed}, status: :ok
  #   else
  #     render json: {error: @recruitment.errors}, status: :not_found
  #   end
  # end

  # PATCH/PUT /recruitments/1
  def update
    if @recruitment.college_id == @college_admin.college.id
      if @recruitment.update(recruitment_params)
        render json: @recruitment, only: [:id]
      else
        render json: @recruitment.errors, status: :unprocessable_entity
      end
    else
      render json: @recruitment.errors, status: :unauthorized
    end
  end

  # DELETE /recruitments/1
  def destroy
    @recruitment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recruitment
      @recruitment = Recruitment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recruitment_params
      params.require(:recruitment).permit(:college_id, :company_id, :role, :des, :jd_link, :ctc, :last_date, :eligibility, :role_type, :location, :completed)
    end





end
