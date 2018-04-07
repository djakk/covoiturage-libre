# coding: utf-8
module ApplicationHelper

  def number_to_age(age)
    t('helpers.number_to_age', age: age).html_safe
  end

  def nl2br(text)
    text_ligned = text.gsub(/\n/, '<br />') if text
    sanitize(text_ligned, tags: %w(br))
  end

  def encode_decode(string)
    string.encode("iso-8859-1").force_encoding("utf-8") unless string.nil?
  end
  alias :ed :encode_decode

  def bootstrap_class_for(flash_type)
    { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning', notice: 'alert-info' }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    html = ''
    flash.each do |msg_type, message|
      html << content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
        content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' })
        message
      end
    end
    html.html_safe
  end

  def trip_steps_breadcrumb(trip, separator = '&rarr;')
    trip.points.map(&:city).join(" #{separator} ").html_safe
  end

  def trip_title(trip, separator = '&rarr;')
    "#{trip_steps_breadcrumb(trip, separator)} le #{l trip.point_from.departure_date, format: :trip_date} à #{l trip.point_from.departure_time, format: :short}".html_safe
  end

  def trip_steps_breadcrumb_with_emphasis(trip, point_a_id = nil, point_b_id = nil, separator = '&rarr;')
    trip.points.map do |p|
      if p.id == point_a_id || p.id == point_b_id
        "<b>#{p.city}</b>"
      else
        p.city
      end
    end.join(" #{separator} ").html_safe
  end

  def admin_page?
    /admin/.match(params[:controller])
  end

  def back_trip_page?
    /new_for_back/.match(params[:action])
  end

  def trip_copy_page?
    /new_from_copy/.match(params[:action])
  end

  def trip_duration(departure_date, departure_time, arrival_date, arrival_time)
    (arrival_time + 24 *60 *60 *(arrival_date - departure_date).to_i) - departure_time
  end

  def display_ddhhmm_from_a_time_duration_in_seconds(the_time_duration_in_seconds)
    the_time_duration_in_minutes = (the_time_duration_in_seconds /60).to_i
    the_time_duration_in_hours = (the_time_duration_in_minutes /60).to_i
    the_time_duration_in_days = (the_time_duration_in_hours /24).to_i

    the_minutes_to_display = the_time_duration_in_minutes %60
    the_hours_to_display = the_time_duration_in_hours %24
    the_days_to_display = the_time_duration_in_days

    if the_minutes_to_display > 0 or (the_time_duration_in_seconds < 60)
      the_minutes_in_text = the_minutes_to_display.to_s + "min"
    else
      the_minutes_in_text = ""
    end
    if the_hours_to_display > 0
      the_hours_in_text = the_hours_to_display.to_s + "h"
    else
      the_hours_in_text = ""
    end
    if the_days_to_display > 0
      the_days_in_text = the_days_to_display.to_s + "j"
    else
      the_days_in_text = ""
    end
    
    (the_days_in_text + " " + the_hours_in_text + " " + the_minutes_in_text).strip
  end
  
  def display_from_integer_to_text_the_number_of_available_seats(the_available_seats_in_integer)
    if the_available_seats_in_integer > 0
      the_number_of_available_seats_in_text = the_available_seats_in_integer.to_s + " place"
      if the_available_seats_in_integer > 1
        the_number_of_available_seats_in_text = the_number_of_available_seats_in_text + "s"
      end
    else
      the_number_of_available_seats_in_text = "Complet"
    end
    the_number_of_available_seats_in_text
  end
end
