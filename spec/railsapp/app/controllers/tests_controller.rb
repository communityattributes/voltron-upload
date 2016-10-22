class TestsController < ApplicationController

  def index
    head :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save(validate: false)
      head :ok
    else
      render plain: "", status: 500
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      head :ok
    else
      render plain: "", status: 500
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :avatar, images: [])
    end

end