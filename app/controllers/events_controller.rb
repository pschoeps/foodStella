class EventsController < ApplicationController
	def create
		@event = current_user.events.build(event_params)
    if @event.save
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @event = Event.find(params[:event][:id])
    @event.destroy
  end

  def update
    @event = Event.find(params[:event][:id])
    @event.update_attributes!(start_at: params[:event][:start_at])
    @event.save

  end

#  def get_events
#    @events = Event.find(:all, :conditions => ["starttime >= '#{Time.at(params['start'].to_i).to_formatted_s(:db)}' and endtime <= '#{Time.at(params['end'].to_i).to_formatted_s(:db)}'"] )
#    events = [] 
#    @events.each do |event|
#        events << {:id => event.id, :title => event.title, :description => event.description || "Some cool description here...", :start => "#{event.starttime.iso8601}", :end => "#{event.endtime.iso8601}"}
#    end
#    render :text => events.to_json
#  end

  def event_params
    params.require(:event).permit(:recipe_id, :start_at, :recipe_name)
  end 
end
