module Api
  module Concerns
    module PayloadValidator
      extend ::ActiveSupport::Concern
      include Api::Concerns::Responder

      ACTION_ARGS_TO_VALIDATE = { 
        create:              [:id, :readings], 
        cumulative_count:    [:id], 
        most_recent_reading: [:id],
        all_data:            []
      }.freeze

      private

      def check_and_parse_readings
        if params[:action].eql?('create')
          params[:readings] = JSON.parse(params[:readings]) if params[:readings].class.eql?(String)
        end
      end

      def validate_args
        valid = true

        ACTION_ARGS_TO_VALIDATE[params[:action].to_sym].each do |arg|
          if  params.key?(arg) && params[arg].present?
            if arg.eql?(:readings)
              valid = check_reading_payload(params[arg])
            end
          else
            valid = false
            return
          end
        end

        return_nil_or_invalid_request(valid)
      end

      
      def check_reading_payload(readings)
        valid = valid_reading_keys?(readings)

        if valid 
          valid = valid_reading_values?(readings)
        else  
          return_nil_or_invalid_request(valid, 'missing required [key,value] for readings')
        end
      end

      def valid_reading_keys?(readings, check_keys = ['timestamp', 'count'])
        reading_keys = readings.map(&:keys)
        reading_keys.any? {|r| r != check_keys } ? false : true
      end

      def valid_reading_values?(readings)
        reading_values = readings.map(&:values)
        reading_values.flatten.any? {|r| r.blank? } ? false : true
      end
    end
  end
end
