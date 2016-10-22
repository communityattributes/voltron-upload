require "rails_helper"

describe "Voltron::Upload::CarrierWave::Uploader::Base" do

  let(:user) { User.new(name: "Test") }

  it "should have an upload hash if file is present" do
    user.avatar = File.open(File.expand_path("../../../../../fixtures/files/1.jpg", __FILE__))
    user.save

    expect(user.avatar.to_upload_hash("test")).to_not be_blank
  end

  it "should not have an upload hash if file does not exist" do
    user.avatar = File.open(File.expand_path("../../../../../fixtures/files/1.jpg", __FILE__))
    user.save

    File.delete(user.avatar.file.path)

    expect(user.avatar.to_upload_hash("test")).to be_nil
  end

end
