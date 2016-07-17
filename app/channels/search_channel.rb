class SearchChannel < ApplicationCable::Channel  
  def subscribed
    stream_from 'search'
  end
end  