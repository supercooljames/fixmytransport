class Assignment < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :user
  belongs_to :creator, :class_name => 'User'
  serialize :data
  belongs_to :problem
  has_many :campaign_events, :as => :described
  has_status({ 0 => 'New', 
               1 => 'In Progress', 
               2 => 'Complete' })

  named_scope :completed, :conditions => ["status_code = ?", self.symbol_to_status_code[:complete]], :order => "updated_at"
  named_scope :incomplete, :conditions => ['status_code != ?',  self.symbol_to_status_code[:complete]], :order => "updated_at"
  validate :validate_write_to_other_fields, :if => Proc.new { |assignment| assignment.task_type_name == 'write-to-other'}
  validate :validate_subject, :if => Proc.new { |assignment| assignment.task_type_name == 'write-to-other' }
  
  # Validation of assignment data for the write-to-other task type
  def validate_write_to_other_fields
    [:name, :email, :reason].each do |field|
      if data.nil? or data[field].blank?
        errors.add(field, ActiveRecord::Error.new(self, field, :blank).to_s)
      end
    end
    if !data.nil? and !data[:email].blank? and data[:email].to_s !~ Regexp.new("^#{MySociety::Validate.email_match_regexp}\$")
      errors.add(:email, ActiveRecord::Error.new(self, :email, :invalid).to_s)
    end
  end

  def validate_subject
    if data.nil? or data[:subject].blank?
      errors.add(:subject, ActiveRecord::Error.new(self, :subject, :blank).to_s)
    end
  end
  
  def task_type
    task_type_name.underscore
  end
  
  def user_name
    if problem
      problem.reporter_name
    end
  end
  
  # complete an assignment, updating its data with any data passed
  def complete!(assignment_data={})
    self.status = :complete
    if self.data
      self.data.update(assignment_data)
    else
      self.data = assignment_data
    end
    ActiveRecord::Base.transaction do
      self.save!
      # if this is an assignment for a campaign, create a campaign event
      if self.problem.campaign
        self.problem.campaign.campaign_events.create!(:event_type => 'assignment_completed', 
                                                      :described => self)
      end
    end
    self
  end

  # class methods
  
  def self.assignment_from_attributes(attributes)
    status = attributes.delete(:status)
    assignment = new(attributes)
    assignment.status = status
    assignment
  end
  
  def self.create_assignment(attributes)
    assignment = assignment_from_attributes(attributes)
    assignment.save!
  end
  
  # Assumes that only the problem reporter ever gets assignments related to the problem
  def self.complete_problem_assignments(problem, assignment_data_hashes)
    assignment_data_hashes.each do |task_type_name, assignment_data|
      assignment = find(:first, :conditions => ["task_type_name = ? and problem_id = ? and user_id = ?", 
                                                task_type_name, problem.id, problem.reporter.id])
      if assignment
       assignment.complete!(assignment_data)
      end
    end
  end
  
end
