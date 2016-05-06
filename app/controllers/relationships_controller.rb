class RelationshipsController < ApplicationController
	def create
		followed_id = params[:id]
		follower_id = current_user.id
		current_user.relationships.create!(followed_id: followed_id)
	end

	def destroy
		followed_id = params[:id]
		follower_id = current_user.id
		@relationship = Relationship.find_by_followed_id_and_follower_id(followed_id, follower_id)
		@relationship.destroy
	end
end
