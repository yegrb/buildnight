module ApplicationHelper
  def errors_for(subject)
    render :partial => "shared/errors", :locals => { :subject => subject } 
  end
end
