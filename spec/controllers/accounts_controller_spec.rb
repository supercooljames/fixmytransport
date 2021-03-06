require 'spec_helper'

describe AccountsController do
  
  shared_examples_for "an action requiring a logged-in user" do 
  
    it 'should require a logged-in user' do
      make_request
      flash[:notice].should == 'You must be logged in to access this page.'
    end
    
  end
  
  describe 'GET #show' do 
  
    def make_request
      get :show
    end
  
    it_should_behave_like 'an action requiring a logged-in user'
    
  end
  
  describe 'GET #edit' do

    def make_request
      get :edit
    end
    
    it_should_behave_like 'an action requiring a logged-in user'
    
    describe 'when a user is logged in' do
    
      before do 
        @mock_user = mock_model(User, :errors => mock('errors', :on => []),
                                      :name => '',
                                      :email => '',
                                      :password => '',
                                      :password_confirmation => '')
        controller.stub!(:current_user).and_return(@mock_user)
      end
      
      it 'should render the edit template' do 
        make_request
        response.should render_template("edit")
      end
    
    end
    
  end

  describe 'PUT #update' do 
    
    def make_request
      put :update, { :user => { :email => 'test@example.com' } }
    end

    it_should_behave_like 'an action requiring a logged-in user'    
    
    describe 'when a user is logged in' do 
      
      before do 
        @mock_user = mock_model(User, :email= => true, 
                                      :password= => true,
                                      :password_confirmation= => true,
                                      :save => true)
        controller.stub!(:current_user).and_return(@mock_user)
      end
    
      it 'should update the current users account info' do 
        @mock_user.should_receive(:email=).with('test@example.com')
        make_request
      end
      
      describe 'if the update is successful' do 
        
        it 'should redirect to the account page' do 
          make_request
          response.should redirect_to(account_path)
        end
        
      end
      
      describe 'if the update is not successful' do 
        
        before do 
          @mock_user.stub!(:save).and_return(false)
        end
      
        it 'should render the edit template' do 
          make_request
          response.should render_template('edit')
        end
        
      end
      
    end
    
  end
  
  describe 'GET #new' do 
    
    def make_request
      get :new
    end
  
    it 'should not require a logged-in user' do 
      make_request
      flash[:notice].should be_nil
    end
    
    it 'should render the "new" template' do 
      make_request
      response.should render_template('new')
    end
    
  end
  
  describe 'POST #create' do 
  
    before do 
      @mock_user = mock_model(User, :valid? => false, 
                                    :name= => true,
                                    :email= => true,
                                    :password= => true, 
                                    :password_confirmation= => true,
                                    :ignore_blank_passwords= => true, 
                                    :registered= => true, 
                                    :registered? => false)
      User.stub!(:find_or_initialize_by_email).and_return(@mock_user)
    end
    
    def make_request
      post :create, { :user => { :name => 'A name',
                                 :email => 'new_user@example.com',
                                 :password => "A password", 
                                 :password_confirmation => "A password confirmation" } }
    end
    
    it 'should find or initialize a user object using the email address' do 
      User.should_receive(:find_or_initialize_by_email).with("new_user@example.com")
      make_request
    end
    
    it 'should set attributes on the user object based on the form params' do 
      @mock_user.should_receive(:name=).with("A name")
      @mock_user.should_receive(:password=).with("A password")
      @mock_user.should_receive(:password_confirmation=).with("A password confirmation")
      make_request
    end

    it 'should test the user object to see if it is valid' do 
      @mock_user.should_receive(:valid?)
      make_request
    end
    
    describe 'if the user model is valid' do 
      
      before do 
        @mock_user.stub!(:valid?).and_return(true)
        @mock_user.stub!(:save_without_session_maintenance)
        @mock_user.stub!(:deliver_new_account_confirmation!)
        @mock_user.stub!(:deliver_already_registered!)
      end
      
      describe 'if this is a new email address, or one that does not have a registered account' do 
        
        before do 
          @mock_user.stub!(:new_record?).and_return(true)
        end
        
        it 'should save the user (not logging them in)' do 
          @mock_user.should_receive(:save_without_session_maintenance)
          make_request
        end
        
        it 'should ask the user to send an account confirmation email' do 
          @mock_user.should_receive(:deliver_new_account_confirmation!)
          make_request
        end
        
        it 'should render the "confirmation_sent" template' do 
          make_request
          response.should render_template("shared/confirmation_sent")
        end
        
      end
      
      describe 'if this is an email address that has a registered account' do 

        before do 
          @mock_user.stub!(:new_record?).and_return(false)
          @mock_user.stub!(:registered?).and_return(true)
        end

        it 'should ask the user to send an "already registered" email' do 
          @mock_user.should_receive(:deliver_already_registered!)
          make_request
        end

        it 'should render the "confirmation_sent" template' do 
          make_request
          response.should render_template("shared/confirmation_sent")          
        end

      end

    end
    
    describe 'if the user model is not valid' do 
    
      before do 
        @mock_user.stub!(:valid?).and_return(false)
      end
      
      it 'should render the "new" template' do 
        make_request
        response.should render_template('new')
      end
      
    end
    
  end
  
  describe 'GET #confirm' do 
    
    def make_request
      get :confirm, :email_token => 'my_token'
    end
    
    it 'should look for a user by perishable token' do 
      User.should_receive(:find_using_perishable_token)
      make_request
    end
    
    describe 'if no user is found using the perishable token' do 

      before do 
        User.stub!(:find_using_perishable_token).with('my_token', 0).and_return(nil)
      end

      it 'should show a notice saying that the account cannot be found' do 
        make_request
        flash[:notice].should == "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process."
      end

      it 'should redirect to the root url' do 
        make_request
        response.should redirect_to(root_url)
      end
    
    end
        
    describe 'if a user can be found using the perishable token param' do
    
      before do 
        UserSession.stub!(:create)
        @mock_user = mock_model(User, :registered? => false, 
                                      :registered= => true, 
                                      :save => true)
        User.stub!(:find_using_perishable_token).with('my_token', 0).and_return(@mock_user)
      end
    
      it 'should redirect to the saved location or the front of the application' do 
        make_request
        response.should redirect_to(root_url)
      end
      
      it 'should show a notice that the user has confirmed their account' do 
        make_request
        flash[:notice].should == 'You have successfully confirmed your account.'
      end
      
      it 'should log the user in' do 
        UserSession.should_receive(:create).with(@mock_user, false)
        make_request
      end
      
      it 'should set the user to registered' do 
        @mock_user.should_receive(:registered=).with(true)
        make_request
      end
      
    end
    
  end
  
end