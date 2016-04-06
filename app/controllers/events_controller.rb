class EventsController < ApplicationController
	def new
		@event = current_user.events.build(event_params)
		if @event.save
			respond_to do |format|
      			format.json { render json: (@event) }
      		end
      	end
    end

    def get_events
      @events = Event.find(:all, :conditions => ["starttime >= '#{Time.at(params['start'].to_i).to_formatted_s(:db)}' and endtime <= '#{Time.at(params['end'].to_i).to_formatted_s(:db)}'"] )
      events = [] 
      @events.each do |event|
        events << {:id => event.id, :title => event.title, :description => event.description || "Some cool description here...", :start => "#{event.starttime.iso8601}", :end => "#{event.endtime.iso8601}"}
      end
    render :text => events.to_json
  end
end
