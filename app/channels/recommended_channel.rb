class RecommendedChannel < ApplicationCable::Channel  
  def subscribed
    stream_from 'recommended'
  end
end  