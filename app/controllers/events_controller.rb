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

    if params[:mobile_destroy]
      redirect_to calendar_user_path(current_user), week_counter: params[:week_counter].to_i
    end
  end

  def update
    @event = Event.find(params[:event][:id])
    @event.update_attributes!(start_at: params[:event][:start_at])
    @event.save

  end

  def change_serving
    @event = Event.find(params[:id])
    @num_servings = params[:num_servings].to_i
    puts "num servings"
    puts @num_servings

    if params[:add] == "true"
      if @event.servings == nil
        new_serving = @num_servings + 1
      else
        new_serving = @event.servings + 1
      end
    else
      if @event.servings == nil 
        new_serving = @num_servings - 1
      else
        new_serving = @event.servings - 1
      end
    end

    puts new_serving

    if new_serving <= 0
      new_serving = 1
    end

    @event.update_attributes!(servings: new_serving)
    if @event.save
      respond_to do |format|
        format.js
      end
    end
  end

  def change_all_servings
    events = params[:events]
    if params[:add] == "true"
      events.each do |event|
        event_object = Event.find(event.to_i)
        if event_object.servings == nil
          new_serving = Recipe.find(event_object.recipe_id).servings + 1
        else
          new_serving = event_object.servings + 1
        end
        event_object.update_attributes!(servings: new_serving)
      end
    else
      events.each do |event|
        event_object = Event.find(event.to_i)
        puts event_object
        if event_object.servings == nil 
          new_serving = Recipe.find(event_object.recipe_id).servings - 1
        else
          new_serving = event_object.servings - 1
        end
        event_object.update_attributes!(servings: new_serving)
      end
    end
    respond_to do |format|
      format.js
    end
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
