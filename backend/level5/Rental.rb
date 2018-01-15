require 'Date'
require_relative 'rentalaction'

class Rental
  attr_writer :car
  attr_reader :id

  def initialize(params = {})
    @id = params[:id]
    @start_date = check_date(params[:start_date])
    @end_date = check_date(params[:end_date])
    @distance = params[:distance]
    @has_deductible_reduction = params[:deductible_reduction]
  end

  def compute_rental_price
    begin
      @rental_price = compute_decreases_per_days.to_i + @distance * @car.price_per_km
      @commission = (@rental_price * 0.3).to_i
      @insurance_fee = @commission / 2
      @assistance_fee = rental_days * 100
      @drivy_fee = @commission - @insurance_fee - @assistance_fee
      compute_actions
      @rental_price
    rescue Exception => e
      p "Error computing rental price for rental ##{@id} : #{e.message}"
      nil
    end
  end

  def deductible_reduction
    return rental_days * 400 if @has_deductible_reduction
    0
  end

  def to_h
    {
        id: @id,
        actions: @actions.collect { |a| a.to_h }
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

  def compute_actions
    @actions = []
    @actions.push(RentalAction.new("driver", "debit", @rental_price + deductible_reduction))
    @actions.push(RentalAction.new("owner", "credit", @rental_price - @commission))
    @actions.push(RentalAction.new("insurance", "credit", @insurance_fee))
    @actions.push(RentalAction.new("assistance", "credit", @assistance_fee))
    @actions.push(RentalAction.new("drivy", "credit", @drivy_fee + deductible_reduction))
  end

end