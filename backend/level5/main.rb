require "json"
require_relative "car"
require_relative "rental"

class DrivyBrain
  def initialize(input_filename, output_filename)
    @input_filename = input_filename
    @output_filename = output_filename
  end

  def start
    data_json = read_input
    return unless data_json
    @cars = load_objects(data_json, :cars) { |o| Car.new(o) }
    @rentals = load_objects(data_json, :rentals) do |o|
      r = Rental.new(o)
      r.car = @cars.find { |c| o[:car_id] == c.id }
      r.compute_rental_price
      r
    end
    write_output
  end

  private
  def read_input
    begin
      data_file = File.read(@input_filename)
      data_json = JSON.parse(data_file, symbolize_names: true)
    rescue Exception => e
      p "Error while reading '#{@input_filename}' : #{e.message}"
      return nil
    end
    data_json
  end

  def load_objects(data_json, object_name)
    if data_json[object_name]
      data_json[object_name].map { |val| yield(val) }
    else
      p "Warning: Object '#{object_name}' not found in #{@input_filename}"
      []
    end
  end

  def write_output
    rentals_list = @rentals.collect { |r| r.to_h }
    begin
      File.open(@output_filename, 'w') do |f|
        f.write(JSON.pretty_generate({ rentals: rentals_list}))
      end
    rescue Exception => e
      p "Error in writing in '#{@output_filename}' : #{e.message}"
    end
  end
end

drivy = DrivyBrain.new('data.json', 'output.json')
drivy.start