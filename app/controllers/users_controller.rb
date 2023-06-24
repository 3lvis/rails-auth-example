class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :set_user, only: [:show, :update, :destroy]
	skip_after_action :update_auth_header, only: %i[destroy]

	def index
		@users = User.all
		render json: @users
	end

	def show		
		render json: @user
	end

	def update		
		if current_user == @user && @user.update(user_params)
			render json: @user
		else
			render json: humanized_errors, status: :unprocessable_entity			
		end
	end

	def destroy
		if current_user == @user
			@user.destroy
		else 
			render json: humanized_errors, status: :unprocessable_entity
		end
	end

	private

	def humanized_errors
		@user.errors.full_messages.join(', ')
	end

	def set_user
		@user = User.find(params[:id])
	  rescue ActiveRecord::RecordNotFound
		render json: { error: "Couldn't find user" }, status: :not_found
	end

	def user_params
		params.permit(:name, :email)
	end
end
