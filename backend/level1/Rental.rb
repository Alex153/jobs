require 'Date'

class Rental
  attr_writer :car
  attr_reader :id

  def initialize(params = {})
    @id = params[:id]
    @start_date = check_date(params[:start_date])
    @end_date = check_date(params[:end_date])
    @distance = params[:distance]
  end

  def rental_price
    begin
      rental_days * @car.price_per_day + @distance * @car.price_per_km
    rescue
      nil
    end
  end

  private
  def check_date(date)
    begin
      Date.parse(date) if date
    rescue ArgumentError => e
      p e.message
      nil
    end
  end

  def rental_days
    return (@end_date - @start_date + 1).to_i if (@start_date && @end_date)
    0
  end
end