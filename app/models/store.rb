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
    state :created, initial: true
    state :processing_email, after_enter: [:generate_verify_code, :send_verify_email]
    state :processing_phone, after_enter: [:generate_verify_code, :send_verify_sms]
    state :verified

    event :process_information do
      transitions from: :created, to: :processing_email
    end

    event :process_email do
      transitions from: :processing_email, to: :processing_phone, guard: :match_verify_code?
    end

    event :process_phone do
      transitions from: :processing_phone, to: :verified, guard: :match_verify_code?
    end

    event :reset do
      transitions from: [:processing_email, :processing_phone, :verified], to: :created
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
end
