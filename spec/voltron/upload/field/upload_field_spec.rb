require "rails_helper"

describe Voltron::Upload::Field::UploadField do

  let(:user) { User.new }

  before(:each) do
    Voltron::Temp.create(uuid: "abc", column: "avatar", file: File.open(File.expand_path("../../../../fixtures/files/1.jpg", __FILE__)), multiple: false)
    Voltron::Temp.create(uuid: "def", column: "images", file: File.open(File.expand_path("../../../../fixtures/files/2.jpg", __FILE__)), multiple: true)
    Voltron::Temp.create(uuid: "ghi", column: "images", file: File.open(File.expand_path("../../../../fixtures/files/3.jpg", __FILE__)), multiple: true)
  end

  it "has a list of uploaded files" do
    user.images = [
      File.open(File.expand_path("../../../../fixtures/files/2.jpg", __FILE__)),
      File.open(File.expand_path("../../../../fixtures/files/3.jpg", __FILE__))
    ]
    user.commit_images = ["def"]

    field = Voltron::Upload::Field::UploadField.new(user, :images, {})

    expect(field.files).to be_a(Array)
    expect(field.files.map { |f| f[:id] }).to eq(["def", "3.jpg"])
    expect(field.commits).to eq({ "def" => "2.jpg" })
  end

  it "has a list of file commit ids" do
    user.commit_avatar = ["abc"]

    field = Voltron::Upload::Field::UploadField.new(user, :avatar, {})
    expect(field.commits).to eq({ "abc" => "1.jpg" })
  end

end
