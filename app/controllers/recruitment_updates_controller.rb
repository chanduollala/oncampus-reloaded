class RecruitmentUpdatesController < ApplicationController
  before_action :set_recruitment_update, only: %i[ update destroy ]
  before_action :authorize_collegeadmin_request, only: %i[ create ]
  before_action :authorize_user_request, only: %i[ show ]

  # GET /recruitment_updates
  def index
    @recruitment_updates = RecruitmentUpdate.all
    render json: @recruitment_updates
  end

  # GET /recruitment_updates/1
  def show
    @recruitment = Recruitment.find(params[:id])
    @recruitment_updates = RecruitmentUpdate.where(recruitment_id: @recruitment.id)
    render json: @recruitment_updates
  end

  # POST /recruitment_updates
  def create
    @recruitment_update = RecruitmentUpdate.new(recruitment_update_params)

    if @recruitment_update.save
      render json: @recruitment_update, status: :created
    else
      render json: @recruitment_update.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recruitment_updates/1
  def update
    if @recruitment_update.update(recruitment_update_params)
      render json: @recruitment_update
    else
      render json: @recruitment_update.errors, status: :unprocessable_entity
    end
  end

  # DELETE /recruitment_updates/1
  def destroy
    @recruitment_update.destroy
  end


  def daywise_updates
    # Get the month and year from the request parameters or wherever you get them
    month = params[:month] # Assuming you pass the month as a parameter
    year = params[:year]   # Assuming you pass the year as a parameter

    # Parse the month string to a Date object
    target_date = Date.parse("#{year}-#{month}-01")

    updates = []
    # Find the updates for the given month
    RecruitmentUpdate.where(start: target_date.beginning_of_month..(target_date.end_of_month + 1.day))
                     .order(:start).each do |update|
      updates.push({
                     id: update.id,
                     recruitment_id: update.recruitment_id,
                     company: Company.find(Recruitment.find(update.recruitment_id).company_id).company_name,
                     title: update.title,
                     type: 'start',
                     date: update.start,
                   })
    end
    RecruitmentUpdate.where(end: target_date.beginning_of_month..(target_date.end_of_month + 1.day))
                               .order(:end).each do |update|
      updates.push({
        id: update.id,
        recruitment_id: update.recruitment_id,
        company: Company.find(Recruitment.find(update.recruitment_id).company_id).company_name,
        title: update.title,
        type: 'end',
        date: update.end
      })
    end


    # Initialize an empty result hash
    result = []

    # Group the updates by date
    grouped_updates = updates.group_by { |update| (update[:date]).to_date }

    # Iterate through the grouped updates and format them
    grouped_updates.each do |date, date_updates|


      result << {date: date, updates: date_updates}
    end

    render json: result
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recruitment_update
      @recruitment_update = RecruitmentUpdate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recruitment_update_params
      params.require(:recruitment_update).permit(:recruitment_id, :title, :description, :start, :end, :link1, :link2, :index)
    end

    def authorize_collegeadmin_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = JsonWebToken.decode(header)
        @college_admin = User.find_by(id:@decoded[:user_id], usertype:'CA')
        if @college_admin
          return @college_admin
        end
        render json: { errors: "access denied" }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    def authorize_user_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = JsonWebToken.decode(header)
        @user = User.find_by(id:@decoded[:user_id])
        if @user
          return @user
        end
        render json: { errors: "access denied" }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end
end
