require "rails_helper"

describe Voltron::Upload::Error do

  it "has a default status of 500" do
    expect(subject.status).to eq(500)
  end

end