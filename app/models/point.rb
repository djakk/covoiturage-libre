# coding: utf-8
class Point < ApplicationRecord

  KINDS = %w( From Step To ).freeze

  belongs_to :trip, inverse_of: :points
  
  attr_accessor :departure_date_in_string
  
  validates_presence_of :kind, :rank, :trip, :lat, :lon, :city, :price, :seats, :departure_date_in_string, :departure_time
  validates_inclusion_of :kind, in: KINDS
  validates_numericality_of :rank
  validate :lat_lon_must_be_set

  validates :price, presence: true, if: Proc.new { |p| !p.price.nil? || p.kind == 'Step' },
                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_from_rank, :set_to_rank
  before_validation :set_departure_date_from_departure_date_in_string

  validates_inclusion_of :departure_date, in: Time.zone.today..Time.zone.today+1.year, message: "Mettre une date située entre aujourd'hui et dans 1 an."
  validates_numericality_of :seats, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :price, only_integer: true, greater_than_or_equal_to: 0
  
  def set_departure_date_from_departure_date_in_string
    # date en texte de type : "vendredi 13 mai 2011" : 4 chiffres -> l'année ; 1 ou 2 chiffres -> le jour ; le mois en lettres est dans I18n.t('date.month_names'), .index("mois en lettres") donne le mois en chiffres
    begin
      the_day_name_in_text, the_day_number_in_text, the_month_in_text, the_year_in_text = self.departure_date_in_string.split(/ +/)
      the_day_in_digits = Integer(the_day_number_in_text)
      the_year_in_digits = Integer(the_year_in_text)
      the_month_in_digits = I18n.t('date.month_names').index(the_month_in_text.downcase)
      self.departure_date = Date.new(the_year_in_digits, the_month_in_digits, the_day_in_digits)
    rescue
      self.departure_date = nil
    end
  end
  
  private

    def lat_lon_must_be_set
      if lat.blank? or lon.blank?
        errors.add(:city, "Vous devez sélectionner une ville dans la liste")
      end
    end


    def set_from_rank
      self.rank = 0 if self.kind == 'From'
    end

    def set_to_rank
      self.rank = Trip::STEPS_MAX_RANK if self.kind == 'To'
    end

end
