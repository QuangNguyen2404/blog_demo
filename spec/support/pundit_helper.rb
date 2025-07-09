# spec/support/pundit_helper.rb
RSpec.configure do |config|
  config.before(:each, type: :controller) do
    # Skip Pundit verification for controller tests
    if described_class < ApplicationController
      allow(controller).to receive(:verify_authorized).and_return(true)
      allow(controller).to receive(:verify_policy_scoped).and_return(true)
    end
  end
end
