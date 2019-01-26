require "rails_helper"

RSpec.describe PublishersController, type: :controller do
  let(:domain) {"test.com"}

  describe '#show' do
    it 'populates domain and returns 200' do
      get :show, domain: domain
      expect(assigns(:domain)).to eq(domain)
      expect(response).to render_template(:show)
    end
  end

  describe '#update_publisher_data' do
    it 'calls the worker' do
      expect(PublisherCrawler).to receive(:perform_async)
      post :update_publisher_data, domain: domain
    end
  end
end
