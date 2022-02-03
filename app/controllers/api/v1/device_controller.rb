module Api
  module V1
    class DeviceController < ApplicationController
      include Api::Concerns::PayloadValidator

      before_action :check_and_parse_readings, :validate_args

      def create
        reading_record = { id: device_params[:id], readings: device_params[:readings] }
        saved = ReadingProcessor.save!(reading_record)        
        reading_record[:readings] = ReadingProcessor.send(:find_device_data, device_params[:id])[:readings]

        render json: { reading_saved: saved }.merge(reading_record), status: :ok
      end

      def cumulative_count
        cumulative_count_value = ReadingProcessor.cumulative_count(device_params[:id])
        render json: response_format(cumulative_count_value), status: :ok
      end

      def most_recent_reading
        res = ReadingProcessor.most_recent_reading(device_params[:id])

        if res.present?
          render json: res, status: :ok
        else
          return_nil_or_invalid_request(res.present?, 'device id was not found')
        end
      end

      def all_data
        render json: ReadingProcessor.data, status: :ok
      end

      private

      def device_params
        params.permit(:id, readings: [:timestamp, :count])
      end
    end
  end
end
