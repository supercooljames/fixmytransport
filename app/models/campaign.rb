class Campaign < ActiveRecord::Base
  belongs_to :initiator, :class_name => 'User'
  has_many :campaign_supporters
  has_many :supporters, :through => :campaign_supporters, :class_name => 'User'
  belongs_to :location, :polymorphic => true
  belongs_to :transport_mode
  has_many :assignments
  has_one :problem
  has_many :incoming_messages
  has_many :campaign_updates
  after_create :add_default_assignment
  validates_presence_of :title, :description, :on => :update
  validates_presence_of :subdomain, :on => :update
  validates_format_of :subdomain, :with => /^[a-z0-9]+[a-z0-9]*$/, 
                                  :on => :update, 
                                  :allow_nil => true,
                                  :message => :only_letters_and_numbers
  validates_format_of :subdomain, :with => /[a-zA-Z]+/, 
                                  :on => :update, 
                                  :allow_nil => true,
                                  :message => :need_one_letter
  validates_length_of :subdomain, :within => 6..16, 
                                  :on => :update, 
                                  :allow_nil => true
  validates_uniqueness_of :subdomain, :on => :update,
                                      :case_sensitive => false
  validates_associated :initiator, :on => :update
  named_scope :confirmed, :conditions => ['confirmed = ?', true], :order => 'created_at desc'
  cattr_reader :per_page, :categories
  @@per_page = 10
  @@categories = ['New route', 'Keep route', 'Get repair', 'Adopt', 'Other']
  
  has_status({ 0 => 'New', 
               1 => 'Confirmed', 
               2 => 'Successful',
               3 => 'Hidden' })

  # instance methods

  def add_default_assignment
    self.assignments.create(:user_id => initiator.id, :task_type_name => 'write-to-transport-operator')
  end
  
  def default_assignment
    self.assignments.first
  end
  
  def supporter_count
    campaign_supporters.confirmed.count
  end
  
  def add_supporter(user, confirmed=false)
    if ! supporters.include?(user)
      supporter_attributes = { :supporter => user }
      if confirmed 
        supporter_attributes[:confirmed_at] = Time.now
      end
      campaign_supporters.create(supporter_attributes)
    end
  end
  
  def remove_supporter(user)
    if supporters.include?(user)
      supporters.delete(user)
    end
  end
  
  def to_param
    (subdomain && !subdomain_changed?) ? subdomain : id.to_s
  end
  
  def domain  
    return "#{subdomain}.#{Campaign.email_domain}"
  end
  
  def valid_local_parts
    [initiator.email_local_part]
  end

  def get_recipient(email_address)
    initiator
  end

  def write_mail_conf
    return false unless subdomain
    local_user = MySociety::Config.get('INCOMING_EMAIL_LOCAL_USER', 'incoming@localhost')
    virtual_domain_file = File.join(Campaign.mail_conf_staging_dir, domain)
    File.open(virtual_domain_file, 'w') do |mail_config_file|
      mail_config_file.write("#DO NOT EDIT: Autogenerated by FixMyTransport: #{__FILE__}\n")
      valid_local_parts.each do |local_part|  
        mail_config_file.write("#{local_part}:\t#{local_user}@#{Campaign.email_domain}\n")
      end
    end
  end

  def events
    events = problem.assignments.completed + incoming_messages + campaign_updates.general
    events = events.sort_by(&:updated_at)
    events = events.reverse
    events
  end
  
  # class methods
  
  def self.mail_conf_staging_dir
    dir = "#{RAILS_ROOT}/data/mail_conf"
    FileUtils.mkdir_p(dir) 
  end
  
  # Synchronize the local mail_conf dir with the live mail conf dirs
  # on the mail servers
  def self.sync_mail_confs
    find(:all).each{ |campaign| campaign.write_mail_conf }
    mail_conf_live_dir = MySociety::Config.get('MAIL_CONF_LIVE_DIR', 'data/mail_conf')
    mailservers = MySociety::Config.get('MAILSERVERS', '').split('|').compact
    mailservers.each do |mailserver|
      system("rsync -r #{mail_conf_staging_dir}/ #{mailserver}:#{mail_conf_live_dir}")
    end
  end
  
  def self.find_by_campaign_email(email)
    local_part, domain = email.split("@")
    subdomain = domain.gsub(/\.#{email_domain}$/, '')
    campaign = find(:first, :conditions => ['subdomain = ?', subdomain]) 
  end
  
  def self.email_domain
    MySociety::Config.get('INCOMING_EMAIL_DOMAIN', 'localhost')
  end
  
  def self.find_by_subdomain(subdomain)
    find(:first, :conditions => ['lower(subdomain) = ?', subdomain.downcase])
  end
  
  def self.find_recent(number)
    confirmed.find(:all, :order => 'created_at desc', 
                         :limit => number, 
                         :include => [:location, :initiator])
  end
  
end
