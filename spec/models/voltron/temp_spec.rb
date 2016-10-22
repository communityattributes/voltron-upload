require "rails_helper"

describe Voltron::Temp do

  before(:each) do
    Voltron::Temp.create(uuid: "abc", column: "avatar", file: File.open(File.expand_path("../../../fixtures/files/1.jpg", __FILE__)), multiple: false)
    Voltron::Temp.create(uuid: "def", column: "images", file: File.open(File.expand_path("../../../fixtures/files/2.jpg", __FILE__)), multiple: true)
    Voltron::Temp.create(uuid: "ghi", column: "images", file: File.open(File.expand_path("../../../fixtures/files/3.jpg", __FILE__)), multiple: true)
  end

  it "can generate a param hash" do
    params = subject.class.to_param_hash("abc", "def", "ghi")
    expect(params).to have_key("avatar")
    expect(params).to have_key("images")
    expect(params["images"]).to be_a(Array)
  end

end
