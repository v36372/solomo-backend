class Store < ActiveRecord::Base
  attr_accessor :received_verify_code

  belongs_to :user
  validates :user_id, presence: true, uniqueness: true
  validates :website, presence: true, unless: :created?
  validates :description, presence: true, unless: :created?
  validates :address, presence: true, unless: :created?
  validates :phone, presence: true, unless: :created?
  validates :location_lat, presence: true, unless: :created?
  validates :location_long, presence: true, unless: :created?

  include AASM
  aasm column: :status, whiny_transitions: false do
    state :created, initial: true, after_exit: [:remove_feedback_content]
    state :processing_email, after_enter: [:generate_verify_code, :send_verify_email]
    state :processing_phone, after_enter: [:generate_verify_code, :send_verify_sms]
    state :processing_staff
    state :verified, after_enter: [:send_congratulation_email, :send_congratulation_sms]

    event :process_information do
      transitions from: :created, to: :processing_email
    end

    event :process_email do
      transitions from: :processing_email, to: :processing_phone, guard: :match_verify_code?
    end

    event :process_phone do
      transitions from: :processing_phone, to: :processing_staff, guard: :match_verify_code?
    end

    event :process_staff do
      transitions from: :processing_staff, to: :verified
    end

    event :reset do
      transitions from: [:processing_email, :processing_phone, :processing_staff, :verified], to: :created, after: [:send_feedback_email]
    end
  end

  def generate_verify_code
    self.verify_code = SecureRandom.hex(4)
    self.save
  end

  def send_verify_email
    StoreMailer.verify_email(self.id).deliver_now
  end

  def send_verify_sms
    sms_client = Twilio::REST::Client.new
    sms_client.messages.create(
      from: Rails.application.secrets.twillio_from,
      to: self.phone,
      body: "Thanks for your registration to become our official stores. Your verify code is: #{self.verify_code.to_s.upcase}"
    )
  end

  def match_verify_code?
    received_verify_code.to_s.upcase == verify_code.to_s.upcase
  end

  def send_feedback_email
    if self.feedback_content.present?
      StoreMailer.send_feedback_email(self.id).deliver_now
    end
  end

  def remove_feedback_content
    self.feedback_content = nil
    self.save
  end

  def send_congratulation_email
    StoreMailer.send_congratulation_email(self.id).deliver_now
  end

  def send_congratulation_sms
    sms_client = Twilio::REST::Client.new
    sms_client.messages.create(
      from: Rails.application.secrets.twillio_from,
      to: self.phone,
      body: "Your store registration has been approved. Please find out more at solomo website."
    )
  end

  def to_api_json
    {
      website: self.website,
      description: self.description,
      address: self.address,
      location_lat: self.location_lat,
      location_long: self.location_long,
      phone: self.phone
    }
  end
end
