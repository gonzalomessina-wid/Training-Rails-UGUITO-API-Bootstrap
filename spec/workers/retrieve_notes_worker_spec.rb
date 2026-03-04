require 'rails_helper'
require 'ostruct'

describe RetrieveNotesWorker do
  describe '#execute' do
    subject(:execute_worker) do
      described_class.new.execute(user.id, params)
    end

    let(:author) { 'Rodrigo Lugo Melgar' }
    let(:params) { { author: author } }
    let(:user) { create(:user, utility: utility) }

    let(:expected_notes_keys) do
      %i[id title content note_type]
    end

    context 'with utility service' do
      let_it_be(:utilities) do
        %i[north_utility south_utility]
      end

      include_context 'with utility' do
        let_it_be(:utility) { create(utilities.sample) }
      end

      context 'when the request to the utility succeeds' do
        let(:expected_status_code) { 200 }
        let(:expected_response_body) do
          { notes: [{ id: 1, title: 'Title', content: 'Content', note_type: 'review' }] }
        end
        let(:utility_service_method) { :retrieve_notes }

        before do
          allow(utility_service_class).to receive(:new).and_return(utility_service_instance)
          allow(utility_service_instance).to receive(utility_service_method)
            .and_return(OpenStruct.new(code: expected_status_code, body: expected_response_body))
          allow(utility_service_instance).to receive(:utility).and_return(utility)
        end

        it 'succeeds' do
          expect(execute_worker.first).to eq 200
        end

        it 'returns notes as array' do
          expect(execute_worker.second[:notes]).to be_instance_of(Array)
        end

        it 'returns the expected note keys' do
          expect(execute_worker.second[:notes].first.keys).to contain_exactly(*expected_notes_keys)
        end
      end

      context 'when the request to the utility fails' do
        let(:expected_status_code) { 500 }
        let(:expected_response_body) { { error: 'message' } }
        let(:utility_service_method) { :retrieve_notes }

        before do
          allow(utility_service_class).to receive(:new).and_return(utility_service_instance)
          allow(utility_service_instance).to receive(utility_service_method)
            .and_return(OpenStruct.new(code: expected_status_code, body: expected_response_body))
          allow(utility_service_instance).to receive(:utility).and_return(utility)
        end

        it 'returns status code obtained from the utility service' do
          expect(execute_worker.first).to eq(expected_status_code)
        end

        it 'returns the body obtained from the utility service' do
          expect(execute_worker.second).to eq(expected_response_body)
        end
      end
    end
  end
end
