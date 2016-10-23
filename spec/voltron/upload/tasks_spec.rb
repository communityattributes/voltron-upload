require "rails_helper"

describe Voltron::Upload::Tasks do

  before(:all) do
    Voltron::Temp.create(created_at: Time.now, uuid: "abc", column: "avatar", file: File.open(File.expand_path("../../../fixtures/files/1.jpg", __FILE__)), multiple: false)
    Voltron::Temp.create(created_at: 1.year.ago, uuid: "def", column: "images", file: File.open(File.expand_path("../../../fixtures/files/2.jpg", __FILE__)), multiple: true)
    Voltron::Temp.create(created_at: 1.year.ago, uuid: "ghi", column: "images", file: File.open(File.expand_path("../../../fixtures/files/3.jpg", __FILE__)), multiple: true)
  end

  it "cleans up out dated temp records" do
    expect { Voltron::Upload::Tasks.cleanup }.to change(Voltron::Temp, :count).from(3).to(1)
  end

end