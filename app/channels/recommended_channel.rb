class RecommendedChannel < ApplicationCable::Channel  
  def subscribed
    stream_from "recommended_#{params[:id]}"
  end
end  