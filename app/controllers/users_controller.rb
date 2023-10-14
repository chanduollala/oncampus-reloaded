class UsersController < ApplicationController
  before_action :set_user, only: %i[ show_student get_image ]
  before_action :authorize_student_request, only: %i[ view_profile update destroy ]
  before_action :authorize_collegeadmin_request, only: %i[ create show_student index_by_branch create_multiple_users ]
  before_action :authorize_user_request, only: %i[search name_and_image]
  before_action :set_user_by_username, only: %i[ login ]

  require 'service/json_web_token'


  ######## Students exclusive APIs ###########

  def show_profile_self
    render_student
  end




  # GET /users
  def index
    @users = User.all
    render json: @users
  end


  def update_dp
    @user = User.find(params[:id])
    @user.image.attach(params[:image])
    if @user.image
      render json: {status: "suuccess", use: @user}, status: :ok
    end
  end

  def name_and_image
    if @user
      name = Name.find_by(user_id: @user.id)
      render json: {name: name, image: (@user.image.attached?)?url_for(@user.image):nil }, status: :ok
    else
      render json: {error: @user.errors}, status: :not_found
    end
  end

  def get_image
    if @user.image.attached?
      redirect_to url_for(@user.image)
    else
      render json: {error: @user.errors}, status: :not_found
    end
  end




  def show_student
    if @user.college === @college_admin.college
      render_student
    else
      render json: {error: "college mismatch"}, status: :forbidden
    end
  end



  # POST /users
  def create
    @user = User.new(user_params)

    if @user.college == @college_admin.college
      if @user.save
        render json: @user, only: [:id], status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      render json: {error: "college mismatch"}, status: :unauthorized
    end
  end


  def create_multiple_users
    require 'service/google_spreadsheets_helper'
    users_json = Service::GoogleSpreadsheetsHelper.create_users_from_spreadsheet(params[:spreadsheet_id])
    if users_json
      users_created = []
      users_failed = []

      users_json.each do |user_data|
        new_user = User.new(user_data[:user])

        if new_user.college == @college_admin.college
          if new_user.save
            user_created_data = {
              id: new_user.id,
              name: "#{user_data[:user][:name_attributes][:first]} #{user_data[:user][:name_attributes][:middle]} #{user_data[:user][:name_attributes][:last]}",
              rollno: user_data[:user][:academic_detail_attributes][:rollno],
              class: "#{Branch.find(user_data[:user][:academic_detail_attributes][:branch_id]).abbr}-#{user_data[:user][:academic_detail_attributes][:section]} #{user_data[:user][:academic_detail_attributes][:yop]}",
            }
            users_created << user_created_data
          else
            failed_user_data = {
              name: "#{user_data[:user][:name_attributes][:first]} #{user_data[:user][:name_attributes][:middle]} #{user_data[:user][:name_attributes][:last]}",
              rollno: user_data[:user][:academic_detail_attributes][:rollno],
              class: "#{Branch.find(user_data[:user][:academic_detail_attributes][:branch_id]).abbr}-#{user_data[:user][:academic_detail_attributes][:section]} #{user_data[:user][:academic_detail_attributes][:yop]}",
            }
            users_failed << {
              user_data: failed_user_data,
              errors: new_user.errors.full_messages }
          end
        else
          users_failed << { user_data: user_data, error: "college mismatch" }
        end
      end

      render json: { users_created: users_created, users_failed: users_failed }, status: :ok
    else
      render json: {error: 'Invalid format'}, status: :bad_request
    end

  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end




  def student_login
    @user = User.find_by(username: params[:username], usertype: 'S')
    if @user
      if @user&.authenticate(params[:password])
        token = Service::JsonWebToken.encode(user_id: @user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'user not found' }, status: :not_found
    end
  end


  def collegeadmin_login
    @user = User.find_by(username: params[:username], usertype: 'CA')
    if @user
      if @user&.authenticate(params[:password])
        token = Service::JsonWebToken.encode(user_id: @user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'user not found' }, status: :not_found
    end
  end


  def search
    #search from search-term
    search_term = params[:search_term]
    @users = User.joins(:name, :academic_detail)
                  .where(
                    'CONCAT(names.first, \' \', names.middle, \' \', names.last) LIKE :term
               OR CONCAT(names.first, \' \', names.middle, names.last) LIKE :term
               OR CONCAT(names.first, names.middle, \' \', names.last) LIKE :term
               OR CONCAT(names.first, names.middle, names.last) LIKE :term
               OR CONCAT(names.first, \' \', names.last) LIKE :term
               OR CONCAT(names.first, names.last) LIKE :term
               OR academic_details.rollno LIKE :term',
                    term: "%#{search_term}%"
                  )
                  .distinct.limit(params[:limit]?params[:limit]:10).offset(params[:offset]?params[:offset]:0)
    render json: @users, only:[:id], include:[academic_detail:{only:[:rollno, :yop, :section], include: {branch:{ only: :abbr}}}, name:{only:[:first , :middle,:last]}]
  end


  def index_by_branch
    query = "branch_id = #{params[:branch_id]}"
    if params[:section]
      query = query+" AND section = '#{params[:section]}'"
    end
    @users = User.joins(:academic_detail).where(query)

    render json: @users, only: [:id], include:[academic_detail:{only:[:rollno, :yop, :section], include: {branch:{ only: :abbr}}}, name:{only:[:first , :middle,:last]}]
  end



  def bulk_upload_template
    require 'service/google_spreadsheets_helper'
    # spread = Service::GoogleSpreadsheetsHelper.create_spreadsheet
    spread = Service::GoogleSpreadsheetsHelper.create_spreadsheet
    render json: { link:  spread}
  end


  def students_data
    require 'rubyXL'
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    headers = [
      "Username", "First name", "Middle name", "Last name",
      "Gender", "Date of birth", "Mother name", "Father name", "Nationality",
      "Email address", "Phone", "Current CGPA", "Roll number", "Year of passing",
      "Branch", "Section", "Active backlogs"
    ]

    headers.each_with_index do |header, index|
      worksheet.add_cell(0, index, header)
    end

    query = User.joins(:academic_detail => :branch)

    if params[:yop].present?
      query = query.where("academic_details.yop = ?", params[:yop])
    end

    if params[:branch].present?
      query = query.where("branches.id= ?", params[:branch])
    end

    if params[:section].present?
      query = query.where("academic_details.section = ?", params[:section])
    end

    users = query

    users.each_with_index do |user, index|
      details = [
        user.username || '',
        user.name&.first || '',
        user.name&.middle || '',
        user.name&.last || '',
        user.personal_detail&.gender || '',
        user.personal_detail&.dob || '',
        user.personal_detail&.mother_name || '',
        user.personal_detail&.father_name || '',
        user.personal_detail&.nationality || '',
        user.contact_detail&.email || '',
        user.contact_detail&.phone || '',
        user.academic_detail&.current_cgpa || '',
        user.academic_detail&.rollno || '',
        user.academic_detail&.yop || '',
        user.academic_detail&.branch&.title || '',
        user.academic_detail&.section || '',
        (user.academic_detail&.backlogs)?'Yes':'No'
      ]

      details.each_with_index do |entry, index2|
        worksheet.add_cell(index+1, index2, entry)
      end
    end

    # worksheet.data_validations = RubyXL::DataValidations.new

    # #validation
    # content = ['Afghanistan','Albania','Algeria']
    # formula = RubyXL::Formula.new(expression: "\"#{content.join(',')}\"")
    # worksheet.data_validations << RubyXL::DataValidation.new(
    #   sqref: RubyXL::Reference.new(0, 0),
    #   formula1: formula,
    #   type: 'list',
    #   prompt_title: nil,
    #   prompt: nil,
    #   show_input_message: true
    # )

    # Set the filename and content type for the attachment
    filename = 'student_data.xlsx'
    content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

    workbook.write(filename)
    send_file filename, filename: filename, type: content_type, disposition: 'attachment'
    # render json: users
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def set_user_by_username
      print params
      @user = User.find_by(username: params[:username])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.permit!
    end

  def authorize_student_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = Service::JsonWebToken.decode(header)
      @user = User.find_by(id:@decoded[:user_id], usertype:'S')
      if @user
        return @user
      end
      render json: { errors: "unauthorised" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def authorize_collegeadmin_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = Service::JsonWebToken.decode(header)
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
      @decoded = Service::JsonWebToken.decode(header)
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


  def render_student1
    render json: @user,
           only: [],
           include: [
             name:{
               only:[
                 :first,
                 :middle,
                 :last
               ]
             },
             personal_detail:{
               only: [
                 :gender,
                 :dob,
                 :mother_name,
                 :father_name,
                 :nationality
               ]
             },
             contact_detail:{
               only:[
                 :email,
                 :phone
               ]
             },
             academic_detail:{
               only:[
                 :current_cgpa,
                 :rollno,
                 :yop,
                 :section,
                 :backlogs
               ],
               include:[
                 branch:{only:[:title, :abbr]}
               ]
             },
             college:{
               only:[
                 :college_name
               ]
             }
           ]
  end

  def render_student
    render json: @user,
           only: [],
           include: [
             name:{
               only:[
                 :first,
                 :middle,
                 :last
               ]
             },
             contact_detail:{
               only:[
                 :email,
                 :phone
               ]
             },
             academic_detail:{
               only:[
                 :current_cgpa,
                 :rollno,
                 :yop,
                 :section,
                 :backlogs
               ],
               include:[
                 branch:{only:[:abbr]}
               ]
             }
           ]
  end
end
