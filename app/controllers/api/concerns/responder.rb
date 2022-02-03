module Api
  module Concerns
    module Responder
      extend ::ActiveSupport::Concern

      private

      def return_nil_or_invalid_request(valid, error = 'missing required arguments')
        unless valid
          render json: {error: error}, status: :bad_request
        end
      end

      def response_format(value)
        { device_id: device_params[:id], cumulative_count_value: value }
      end
    end
  end
end
