class RaterController < ApplicationController

  def create
    if user_signed_in?
      obj = params[:klass].classify.constantize.find(params[:id])
      obj.rate params[:score].to_f, current_user, params[:dimension] #, 'review'
      # obj.rate.update_attributes(:rateable_type => 'review')

      render :json => true
    else
      render :json => false
    end
  end
end
