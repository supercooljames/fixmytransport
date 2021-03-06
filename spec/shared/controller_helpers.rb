module SharedBehaviours
  
  module ControllerHelpers
    
    shared_examples_for "an action that requires the campaign initiator" do 

      describe 'when the current user is not the campaign initiator' do

        before do 
          @campaign_user = mock_model(User, :name => "Campaign User")
          @mock_campaign = mock_model(Campaign, :initiator => @campaign_user,
                                                :editable? => true, 
                                                :status => :confirmed,
                                                :visible? => true)
          Campaign.stub!(:find).and_return(@mock_campaign)
        end

        describe 'when there is a current user' do 

          it 'should render the "wrong user template"' do 
            controller.stub!(:current_user).and_return(mock_model(User))
            make_request @default_params
            response.should render_template("shared/wrong_user")
          end

          it 'should show an appropriate message' do 
            controller.stub!(:current_user).and_return(mock_model(User))
            make_request @default_params
            assigns[:access_message].should == @expected_access_message 
          end

        end
      end
    end
    
    shared_examples_for "an action requiring a visible campaign" do 
    
      it 'should return a 404 for a campaign that is not visible' do 
        @invisible_campaign = mock_model(Campaign, :editable? => true, 
                                                   :visible? => false)
        Campaign.stub!(:find).and_return(@invisible_campaign)
        make_request
        response.status.should == '404 Not Found'
      end
      
    end
    
  end
end
