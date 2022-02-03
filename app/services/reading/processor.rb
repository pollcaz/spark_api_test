require 'json'

module Reading
  class Processor
    attr_accessor :data
    attr_reader :error

    DEFAULT_FILE_NAME = './app/services/reading/readings.json'.freeze

    def initialize(file_name = nil)
      @data = load_data(file_name)
      self
    rescue StandardError => e
      @error = e
      @data = []  
    end

    def cumulative_count(devide_id)
      device_data = data.select { |record| record[:id].eql?(devide_id) }&.first
      device_data.present? ? return_cumulative_count(device_data) : 0
    end

    def most_recent_reading(devide_id)
      device_data = find_device_data(devide_id)

      if device_data.present?
        device_data[:readings].last
      else
        {}
      end
    end

    def save!(reading_hash)
      new_device_readings = reading_hash[:readings].uniq
      device_data = find_device_data(reading_hash[:id])

      if device_data.present?
        @data = @data.delete_if {|device| device[:id].eql?(reading_hash[:id]) }
        @data << { id: device_data[:id], readings: union_and_sort_readings(device_data[:readings], new_device_readings) }
      else
        @data << { id: reading_hash[:id], readings: sort_array_of_hashes(new_device_readings) }
      end

      true 
    end

    def reload!
      @data = load_data
    end

    private

    def union_and_sort_readings(device_data_readings, new_device_readings)
      all_readings = (device_data_readings + new_device_readings).uniq
      sort_array_of_hashes(all_readings)
    end

    def sort_array_of_hashes(new_device_readings, key: :timestamp)
      new_device_readings.sort_by { |device_reading| device_reading[key] }
    end

    def find_device_data(devide_id)
      data.select { |record| record[:id].eql?(devide_id) }&.first
    end

    def load_data(file_name = nil)
      file = File.read(file_name || DEFAULT_FILE_NAME)
      JSON.parse(file).map { |r| r.deep_symbolize_keys }
    end

    def return_cumulative_count(device_data)
      device_data[:readings].sum {|r| r[:count].to_i }
    end
  end
end
