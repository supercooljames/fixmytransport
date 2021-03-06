require 'spec_helper'

describe AssignmentsController do
  
  shared_examples_for "an action requiring an expert" do 
  
    describe 'and the current user is not an expert' do

      before do
        mock_user = mock_model(User, :is_expert? => false)
        controller.stub!(:current_user).and_return(mock_user)
      end

      it 'should render the "wrong_user" template' do 
        make_request
        response.should render_template('shared/wrong_user')
      end

      it 'should assign variables for an appropriate message' do 
        make_request
        assigns[:name].should == 'a FixMyTransport boffin'
        assigns[:access_message].should == @expected_access_message
      end

    end

    describe 'and there is no current user' do 

      it 'should redirect to the login page with a message' do 
        controller.stub!(:current_user).and_return(nil)
        make_request
        response.should redirect_to(login_url)
        flash[:notice].should == "Login as a FixMyTransport boffin to create an assignment for this campaign"
      end

    end

  end
    
  describe 'GET #new' do
    
    before do 
      @expert_user = mock_model(User, :is_expert? => true,
                                      :name => 'Ken Expert')
      @initiator = mock_model(User, :name => 'Joe Bloggs',
                                    :first_name => 'Joe')
      mock_assignments = mock('assignments', :build => true)
      @campaign = mock_model(Campaign, :visible? => true,
                                       :editable? => true, 
                                       :initiator => @initiator,
                                       :assignments => mock_assignments)
      Campaign.stub!(:find).and_return(@campaign)
      @expected_access_message = :assignments_new_access_message
    end
    
    def make_request
      get :new, :campaign_id => 44
    end
    
    it_should_behave_like "an action requiring a visible campaign"
    it_should_behave_like "an action requiring an expert"
    
    describe 'if the current user is an expert' do 
      
      before do 
        controller.stub!(:current_user).and_return(@expert_user)
      end
      
      it 'should render the new template' do 
        make_request
        response.should render_template("new")
      end
  
    end
    
  end
  
  describe 'POST #create' do 
  
    before do
      @expert_user = mock_model(User, :is_expert? => true)
      @initiator = mock_model(User, :name => 'Joe Bloggs')
      @campaign_events_mock = mock('campaign events association', :create! => nil)
      @campaign = mock_model(Campaign, :visible? => true,
                                       :editable? => true, 
                                       :initiator => @initiator,
                                       :problem => mock_model(Problem),
                                       :campaign_events => @campaign_events_mock)
      Campaign.stub!(:find).and_return(@campaign)
      @expected_access_message = :assignments_create_access_message
      @assignment = mock_model(Assignment, :save => true, :user => @initiator)
      Assignment.stub!(:assignment_from_attributes).and_return(@assignment)
      CampaignMailer.stub!(:deliver_write_to_other_assignment)
    end
    
    def make_request
      post :create, { :campaign_id => 44, 
                      :name => 'A name', 
                      :email => 'An email', 
                      :reason => 'A reason', 
                      :subject => 'subject',
                      :draft_text => 'Some draft text' } 
    end
    
    it_should_behave_like "an action requiring a visible campaign"
    it_should_behave_like "an action requiring an expert"
    
    
    describe 'if the current user is an expert' do 
      
      before do 
        controller.stub!(:current_user).and_return(@expert_user)
      end
    
      it 'should create an assignment from the attributes passed' do 
        expected_data = { :name => 'A name', 
                          :email => 'An email', 
                          :reason => 'A reason', 
                          :subject => 'subject',
                          :draft_text => 'Some draft text' }
        Assignment.should_receive(:assignment_from_attributes).with(:campaign => @campaign, 
                                                                    :data => expected_data, 
                                                                    :problem => @campaign.problem,
                                                                    :status => :new, 
                                                                    :creator => @expert_user,
                                                                    :task_type_name => 'write-to-other',
                                                                    :user => @campaign.initiator)
        make_request
      end
    
      it 'should try to save the assignment' do 
        @assignment.should_receive(:save)
        make_request
      end
    
      describe 'if the assignment can be saved' do 
    
        before do 
          @assignment.stub!(:save).and_return(true)
        end
        
        it 'should send an email to the assignment user telling them about the assignment' do 
          CampaignMailer.should_receive(:deliver_write_to_other_assignment)
          make_request
        end
        
        it 'should redirect to the campaign page' do 
          make_request
          response.should redirect_to(campaign_path(@campaign))
        end
        
        it 'should show a notice saying that the user has been notified' do 
          make_request
          flash[:notice].should == "Thanks! We've sent your advice to Joe Bloggs"
        end

        it 'should add an "assignment_given" event to the campaign' do
          @campaign_events_mock.should_receive(:create!).with({ :event_type => 'assignment_given',
                                                                :described => @assignment })
          make_request
        end
    
      end
    
      describe 'if the assignment cannot be saved' do 
    
        before do 
          @assignment.stub!(:save).and_return(false)
        end
        
        it 'should render the "new" template' do
          make_request
          response.should render_template('new')
        end
      end
    end
  end
  
  describe 'GET #show' do 
    
    before do 
      @campaign = mock_model(Campaign, :editable? => true, 
                                       :visible? => true, 
                                       :assignments => [])
      Campaign.stub!(:find).and_return(@campaign)
      @default_params = { :campaign_id => 55, :id => 22 }
      @mock_assignment = mock_model(Assignment, :task_type_name => 'write-to-other')
      @campaign.assignments.stub!(:find).and_return(@mock_assignment)
    end
  
    def make_request(params=@default_params)
      get :show, params
    end
    
    it_should_behave_like "an action requiring a visible campaign"
    
    it 'should get the assignment' do 
      @campaign.assignments.should_receive(:find).with("22")
      make_request
    end
    
    describe 'if the assignment task type is not "write-to-other"' do 
      
      before do 
        @mock_assignment.stub!(:task_type_name).and_return('write-to-transport-organization')
      end
      
      it 'should return a 404' do 
        make_request
        response.status.should == '404 Not Found'
      end
    
    end
    
    describe 'if the assignment task type is "write-to-other"' do 
    
      before do 
        @mock_assignment.stub!(:task_type_name).and_return('write-to-other')
      end
      
      it 'should render the "show" template' do 
        make_request
        response.should render_template('show')
      end
    
    end
    
  end
  
end