require 'rails_helper'

def parser_body(body_response)
  JSON.parse(body_response).deep_symbolize_keys
end

RSpec.describe ::Api::V1::DeviceController do  
  describe 'POST #create' do
    let(:reading1_ok) { { timestamp: '2022-02-04T16:09:15+01:00', count: '3' } }
    let(:reading2_ok) { { timestamp: '2022-02-04T16:07:15+01:00', count: '1' } }
    let(:malformed_reading) { { timestamp: 'wrong format', count: nil } }
    let(:new_readings) { [reading1_ok, reading2_ok] }
    let(:device_id) { '36d5658a-6908-479e-887e-a949ec199272' }
    let(:params) { { id: device_id, readings: new_readings } }

    before do
      post :create, params: params
    end

    after do
      ReadingProcessor.reload!
    end

    let(:expected_response) { { reading_saved: true }.merge(params) }

    it 'returns a hash with reading_saved as true' do
      expect(parser_body(response.body)[:reading_saved]).to be_truthy
    end

    context 'when device_id already exists' do
      it 'adds to the data the new readings' do
        expect(ReadingProcessor.data.first[:readings].size).to eq(4)
      end

      it 'sorts readings data in ascendent order' do
        expect(parser_body(response.body)[:readings].last).to eq(reading1_ok)
      end
    end

    context 'when send malformed readings' do
      let(:new_readings) { [reading1_ok, malformed_reading, reading2_ok] }

      it 'returns a bad request status(400)' do
        expect(response.status).to eq(400)
      end

      it 'returns a hash with an error message' do
        expect(parser_body(response.body)).to eq({ error: 'missing required arguments' })
      end
    end
  end

  describe 'GET #all_data' do
    before do
      post :all_data
    end

    it 'returns a successful request status(200)' do
      expect(response.status).to eq(200)
    end

    it 'returns all devices readings data storage until this moment' do
      expect(JSON.parse(response.body).present?).to be_truthy
    end
  end

  describe 'GET #cumulative_count' do
    let(:device_id) { '36d5658a-6908-479e-887e-a949ec199272' }
    let(:value) { 17 }
    let(:expected_response) { { device_id: device_id, cumulative_count_value: value } }


    before do
      get :cumulative_count, params: { id: device_id }
    end

    context 'when device_id exists' do
      it 'returns a cumulative value for this case is 17' do
        expect(parser_body(response.body)).to eq(expected_response)
      end
    end

    context 'when device_id does not exist' do
      let(:device_id) { '36d5658a-6908-479e-887e-a949ec19927x' }
      let(:value) { 0 }

      it 'returns a hash with cumulative_count_value as 0' do
        expect(parser_body(response.body)).to eq(expected_response)
      end
    end
  end

  describe 'GET #most_recent_reading' do
    let(:device_id) { '36d5658a-6908-479e-887e-a949ec199272' }
    let(:expected_response) { { timestamp: '2021-09-29T16:09:15+01:00', count: 15 } }

    before do
      get :most_recent_reading, params: { id: device_id }
    end

    context 'when device_id exists' do
      it 'returns its most recent reading' do
        expect(parser_body(response.body)).to eq(expected_response)
      end
    end

    context 'when device_id does not exist' do
      let(:device_id) { '36d5658a-6908-479e-887e-a949ec19927x' }
      let(:expected_response) { { error: 'device id was not found' } }

      it 'returns a bad request status(400)' do
        expect(response).to have_http_status(400)
      end

      it 'returns a hash with the error message' do
        expect(parser_body(response.body)).to eq(expected_response)
      end
    end
  end


end