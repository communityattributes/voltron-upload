require "rails_helper"

describe Voltron::Upload::Error do

  it "has a default status of not_acceptable" do
    expect(subject.status).to eq(:not_acceptable)
  end

end