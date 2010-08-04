require 'spec_helper'

describe AssignmentsController do

  describe 'responding to PUT #update' do 
  
    def make_request
      put :update, { :id => 11,
                     :campaign_id => 22, 
                     :user_id => 33, 
                     :task_id => 44, 
                     :data => { :some => :data }, 
                     :status => :complete }
    end
    
    it 'should update the assignment identified by the id param of the request' do 
      Assignment.should_receive(:update).with(11, { :campaign_id => '22', 
                                                    :user_id => '33', 
                                                    :task_id => '44', 
                                                    :data => { 'some' => :data }, 
                                                    :status => :complete })
      make_request
    end
    
  end

end