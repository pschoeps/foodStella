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
    if params[:id]
      @event = Event.find(params[:id])
    else
      start_at = params[:start_at].gsub!('T',' ')
      puts start_at
      @events = current_user.events.where(:recipe_id => params[:recipe_id])
      @events.each do |event|
        puts event.start_at
        puts start_at
        puts "break"
      end
      @event = @events.where(:start_at => start_at).last
      puts @event

    end

    @event.destroy
  end

  def update
    start_at = params[:event][:start_at].gsub!('T',' ')
    if params[:event][:id]
      @event = Event.find(params[:event][:id])
    else
      @events = current_user.events.where(:recipe_id => params[:event][:recipe_id])
      @event = @events.where(:start_at => start_at).last
    end

    @event.update_attributes!(start_at: start_at)
    @event.save

  end

  def get_events
    @events = Event.find(:all, :conditions => ["starttime >= '#{Time.at(params['start'].to_i).to_formatted_s(:db)}' and endtime <= '#{Time.at(params['end'].to_i).to_formatted_s(:db)}'"] )
    events = [] 
    @events.each do |event|
        events << {:id => event.id, :title => event.title, :description => event.description || "Some cool description here...", :start => "#{event.starttime.iso8601}", :end => "#{event.endtime.iso8601}"}
    end
    render :text => events.to_json
  end

  def event_params
    params.require(:event).permit(:recipe_id, :start_at, :end_at, :recipe_name)
  end 
end
