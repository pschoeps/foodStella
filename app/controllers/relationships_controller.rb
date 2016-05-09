class RelationshipsController < ApplicationController
	def create
		followed_id = params[:id]
		follower_id = current_user.id
		@relationship = current_user.relationships.create!(followed_id: followed_id)
		# respond_to do |format|
		# 	if @relationship.save
		# 		format.json { render json: @relationship, status: :created, location: @relationship }
		# 	else
		# 		format.json {render json: @relationship.erros, status: :unprocessable_entity}
		# 	end
		# end
	end

	def destroy
		followed_id = params[:id]
		follower_id = current_user.id
		@relationship = Relationship.find_by_followed_id_and_follower_id(followed_id, follower_id)
		@relationship.destroy
	end
end
