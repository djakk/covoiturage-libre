# coding: utf-8
class DepartureTimesValidator < ActiveModel::Validator
  def validate(record)
    # sort trip points by rank
    sorted_points = record.points.sort do |a, b|
      if a[:rank].nil? || b[:rank].nil?
        0
      else
        a[:rank] <=> b[:rank]
      end
    end
    
    if sorted_points.any?
      if sorted_points.length > 1
        # check for growing values of points prices
        previous_time = sorted_points[0].departure_time
        previous_date = sorted_points[0].departure_date
        sorted_points[0..-1].each do |point|
          if point["departure_time"].nil?
            point.errors[:departure_time] << "L'heure doit être indiquée."
            return false
          end
          if point["departure_date"].nil?
            point.errors[:departure_date] << "Le jour doit être indiqué."
            return false
          end
        sorted_points[1..-1].each do |point|
          if point["departure_date"] < previous_price
            record.errors[:price] << "Les prix des étapes doivent être indiqués dans l\'ordre croissant."
            return false
          end

          previous_price = point["price"]
        end
      end
    end

    true
  end
end
