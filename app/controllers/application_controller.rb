class ApplicationController < ActionController::API

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


end
