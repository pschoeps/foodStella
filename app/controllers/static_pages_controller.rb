class StaticPagesController < ApplicationController
  def home
  end

  private
    def determine_layout
  	  #set a layout variable for determining weather or not to set a layout in the application.html file.  If this variable is set to 
  	  #false (in individual controller instances), then the navbar and footer will not be displayed.
      @layout = false
    end
end

