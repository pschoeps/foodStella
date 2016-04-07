module FriendshipHelper
    #return status of a friendship
    def friendship_status(user, friend)
        friendship = Friendship.find_by_user_id_and_friend_id(user, friend)
        return "" if friendship.nil?
        case friendship.status
        when 'requested'
          "#{friend.username} has requested you"
        when 'pending'
          "Pending"
        when 'accepted'
          "Friends"
        end
    end

end
