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
      price = compute_decreases_per_days.to_i + @distance * @car.price_per_km
      @commission = (price * 0.3).to_i
      @insurance_fee = @commission / 2
      @assistance_fee = rental_days * 100
      @drivy_fee = @commission - @insurance_fee - @assistance_fee
      price
    rescue
      nil
    end
  end

  def to_h
    {
        id: @id,
        price: rental_price,
        commission: {
            insurance_fee: @insurance_fee,
            assistance_fee: @assistance_fee,
            drivy_fee: @drivy_fee
        }
    }
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

  def compute_decreases_per_days
    (1..rental_days).sum do |d|
      case d
        when 1
          @car.price_per_day
        when 2..4
          @car.price_per_day * 0.9
        when 5..10
          @car.price_per_day * 0.7
        else
          @car.price_per_day * 0.5
      end
    end
  end
end