require "rails_helper"

describe Voltron::Upload do

  let(:controller) { TestsController.new }

  it "has a version number" do
    expect(Voltron::Upload::VERSION).not_to be nil
  end

  it "can be uploadable" do
    expect(controller.class.respond_to?(:uploadable)).to eq(true)
    controller.class.uploadable :users
  end

  it "should have an uploader" do
    controller.class.uploadable :users
    expect(controller.uploader).to be_a(Voltron::Uploader)
  end

end
