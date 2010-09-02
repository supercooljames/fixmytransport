class StoriesController < ApplicationController
  protect_from_forgery :except => [:find]
  cache_sweeper :story_sweeper, :only => :confirm
  
  def new
    @title = t :new_story
    @story = Story.new()
  end
  
  def index
    @title = t(:recent_stories)
    @stories = Story.paginate( :page => params[:page], 
                                  :conditions => ['confirmed = ?', true],
                                  :order => 'created_at DESC' )
    if !@stories.empty? 
      @updated = @stories.first.updated_at
    end
    respond_to do |format|
      format.html
      format.atom { render :template => 'shared/stories.atom.builder', :layout => false }
    end
  end
  
  def find
    @location_search = LocationSearch.new_search!(session_id, params)
    story_attributes = params[:story]
    story_attributes[:location_search] = @location_search
    @story = Story.new(story_attributes)
    if !@story.valid? 
      @title = t :new_story
      render :new
    else
      @story.location_from_attributes
      if @story.locations.size == 1
         redirect_to location_url(@story.locations.first)
      elsif !@story.locations.empty?
        @story.locations = @story.locations.sort_by(&:name)
        location_search.add_choice(@story.locations)
        @title = t :multiple_locations
        render :choose_location
      else
        @title = t :new_story
        render :new
      end
    end
  end
  
  def choose_location
  end
  
  def confirm
    @story = Story.find_by_token(params[:email_token])
    if @story
      @story.update_attribute(:confirmed, true)
    else
      @error = t(:story_not_found)
    end
  end
  
  def show
    @story = Story.find(params[:id])
    @title = @story.title
  end
  
  private
  
  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{RAILS_ROOT}/public/404.html", :status => :not_found
  end
  
end