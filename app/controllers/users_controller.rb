class UsersController < ApplicationController
  def index
    @user = User.where(admin: false)
  end
  
  def new
    @user = User.new
  end

  def add_user
    @user = User.new(user_params)
     if @user.save
       redirect_to root_path
     end
  end

  private

  def user_params
    params.require(:user).permit(:email, :admin, :name, :designation)
  end
end
