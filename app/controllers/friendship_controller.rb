class FriendshipController < ApplicationController
    before_filter :setup_friends
    
    #send a friend request
    def create
        Friendship.request(current_user, @friend)
        flash[:success] = 'Request Sent'
        redirect_to :back
    end
    
    def accept
        if current_user.requested_friends.include?(@friend)
            Friendship.accept(current_user, @friend)
            flash[:success] = "Request Accepted"
            redirect_to :back
        end
    end
    
    def decline
        if current_user.requested_friends.include?(@friend)
            Friendship.breakup(current_user, @friend)
            flash[:success] = "Friendship Declined"
            redirect_to :back
        end
    end
    
    def delete
        if current_user.friends.include?(@friend)
            Friendship.breakup(current_user, @friend)
            flash[:success] = "Friend Removed"
            redirect_to :back
        end
    end
    
    def setup_friends
        @friend = User.find(params[:id])
    end

end
