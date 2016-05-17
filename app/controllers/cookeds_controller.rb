class CookedsController < ApplicationController
	def create
		cooked_id = params[:id]
		cooker_id = current_user.id
		@cooked = current_user.cookeds.create!(cooked_id: cooked_id)
	end

	def destroy
		cooked_id = params[:id]
		cooker_id = current_user.id
		@cooked = Cooked.find_by_cooked_id_and_cooker_id(cooked_id, cooker_id)
		@cooked.destroy
	end
end
