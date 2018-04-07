# coding: utf-8
class Trip < ApplicationRecord
  include Trips::Search
  
  # use of this classification https://en.wikipedia.org/wiki/Hotel_rating
  CAR_RATINGS = %w(standard comfort first_class luxury).freeze
  STATES = %w(pending confirmed deleted).freeze
  
  STEPS_MAX_RANK = 16 # maximum nb of steps = max rank - 1
  SEARCH_DISTANCE_IN_METERS = 25_000
  
  # only for search purpose : 
  attr_accessor(
    :the_previous_trip__departure_date, 
    :departure_date,
    :departure_time,
    :arrival_date, 
    :arrival_time, 
    :price, 
    :seats
  )
  
  has_many :points, -> { order('rank asc') }, inverse_of: :trip, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_secure_token :confirmation_token
  has_secure_token :edition_token
  has_secure_token :deletion_token

  accepts_nested_attributes_for :points, allow_destroy: true, reject_if: proc {|attrs| attrs[:city].blank? && attrs[:kind]=='Step' }

  validates_presence_of :title, :name, :email, :comfort, :state
  validates_inclusion_of :smoking, in: [true, false]
  validates_inclusion_of :comfort, in: CAR_RATINGS
  validates_inclusion_of :state, in: STATES
  validates_numericality_of :age, only_integer: true, allow_blank: true, greater_than: 0, less_than: 100

  validate :must_have_from_and_to_points
  validates_acceptance_of :terms_of_service
  validates :email, email: true
  #validates_with PricesValidator
  #validate :ordered_departure_dates_and_time_of_the_points
  
  before_validation :strip_whitespace
  
  def strip_whitespace
    self.email = strip_value(self.email)
    self.name = strip_value(self.name)
    self.phone = strip_value(self.phone)
    self.description = strip_value(self.description)
  end

  after_create :send_confirmation_email

  # eager load points each time a trip is requested
  default_scope { includes(:points).order('created_at ASC') }
  
  def to_param
    confirmation_token
  end

  # access the departure point that comes eager loaded with a trip
  def point_from
    points.find { |point| point.kind == 'From' }
  end

  # access the destination point that comes eager loaded with a trip
  def point_to
    points.find { |point| point.kind == 'To' }
  end

  # access the steps point that comes eager loaded with a trip
  def step_points
    points.select { |point| point.kind == 'Step' }
  end

  
  def confirm!
    self.update_attribute(:state, 'confirmed')
    self.send_information_email
  end

  def soft_delete!
    self.update_attribute(:state, 'deleted')
  end

  def confirmed?
    state == 'confirmed'
  end

  def deleted?
    state == 'deleted'
  end

  def send_confirmation_email
    UserMailer.trip_confirmation(self).deliver_later
  end

  def send_information_email
    UserMailer.trip_information(self).deliver_later
  end

  def clone_without_date
    new_trip = self.dup
    new_trip.points = self.points.map { |p| p.dup }
    new_trip
  end

  def clone_as_back_trip
    new_trip = self.dup
    new_trip.points = self.points.reverse.map { |p| p.dup }
    new_trip.points.first.kind = 'From'
    new_trip.points.last.kind = 'To'
    # reverse ranks
    new_trip.points.last.rank = new_trip.points.first.rank
    new_trip.points.first.rank = 0
    new_trip.step_points.each_with_index { |sp, index| sp.rank = index + 1 }

    new_trip
  end
  
  # for search purpose : 
  def before_actual_time
    self.departure_time.hour < Time.now.hour || (self.departure_time.hour == Time.now.hour && self.departure_time.min <= Time.now.min)
  end

  # for search purpose : 
  def is_before_today?
    self.departure_date == Date.today && self.before_actual_time
  end

  # for search purpose : 
  def is_strictly_before(the_date)
    self.departure_date < the_date
  end

  # for search purpose : 
  def is_strictly_after(the_date)
    self.departure_date > the_date
  end
  
  
  def is_on_the_road?
    self.point_from.departure_date == Date.today && (self.point_from.departure_time.hour < Time.now.hour || (self.point_from.departure_time.hour == Time.now.hour && self.point_from.departure_time.min <= Time.now.min))
  end
  
  def calculate_the_available_seats_between_two_points_in_index(the_start_point__in_index, the_end_point__in_index)
    # number of availables seats = minimum on points.seats between the_start_point__in_index and the_end_point__in_index, without the_start_point__in_index
    the_points_between_start_and_end = self.points[the_start_point__in_index +1..the_end_point__in_index]
    the_seats = the_points_between_start_and_end.map { |a_point| a_point.seats }.min
    the_seats
  end

  def calculate_the_price_between_two_points_in_index(the_start_point__in_index, the_end_point__in_index)
    # price : sum on points.price between the_start_point__in_index and the_end_point__in_index, without the_start_point__in_index
    the_points_between_start_and_end = self.points[the_start_point__in_index +1..the_end_point__in_index]
    the_price = the_points_between_start_and_end.map { |a_point| a_point.price }.sum
    the_price
  end

  def get_the_minimum_price_with_zero_instead_of_nil
    the_minimum_price_with_zero_instead_of_nil = self.minimum_price
    if the_minimum_price_with_zero_instead_of_nil.nil?
      the_minimum_price_with_zero_instead_of_nil = 0
    end
    the_minimum_price_with_zero_instead_of_nil
  end
  
  private

    def must_have_from_and_to_points
      if points.empty? or point_from.nil? or point_to.nil?
        errors.add(:base, "Le départ et l'arrivée du voyage sont nécessaires.")
      end
    end

    def ordered_departure_dates_and_time_of_the_points__TO_DO
      if self.points.length >= 1
        the_trips_ordered[0].the_previous_trip__departure_date = nil
      end
      if the_trips_ordered.length >= 2
        for a_trip, a_previous_trip in the_trips_ordered[1..-1].zip(the_trips_ordered[0..-2])
          a_trip.the_previous_trip__departure_date = a_previous_trip.departure_date
        end
      end
    end

end
