class Wechat::My::UsersController < Wechat::My::BaseController
  before_action :set_user

  def show
    respond_to do |format|
      format.js
      format.html
      format.json { render json: @profile }
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @current_user.update profile_params
        format.html { redirect_to my_profile_url, notice: 'Profile was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  private
  def set_user
    @profile = current_user.profile || current_user.create_profile
  end

  def profile_params
    params.fetch(:profile, {}).permit(
      :title,
      :gender,
      :birthday_type,
      :birthday,
      :highest_education,
      :degree,
      :major,
      :work_experience
    )
  end

end
