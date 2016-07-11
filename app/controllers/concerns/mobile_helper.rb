module MobileHelper 
  def check_for_mobile
    #session[:mobile_override] = params[:mobile] if params[:mobile]
    prepare_for_mobile if mobile_device?
  end

  #alters the file path by redirecting to a different file tree locaed in app/views_mobile
  def prepare_for_mobile
    prepend_view_path Rails.root + 'app' + 'views_mobile'
  end
  
  #checks if the device is mobile
  def mobile_device?
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      # Season this regexp to taste.
      (request.user_agent =~ /Mobile|webOS|iPhone|iPad/) 
    end
  end
end