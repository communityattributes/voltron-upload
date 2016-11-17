require "rails_helper"

describe TestsController, type: :controller do

  let(:file1) { fixture_file_upload("files/1.jpg", "image/jpeg") }
  let(:file2) { fixture_file_upload("files/file.txt", "text/plain") }

  before(:each) { subject.class.uploadable :users }

  it "has an upload action" do
    expect(subject.methods).to include(:upload)
  end

  it "has an uploader" do
    expect(subject.uploader).to be_a(Voltron::Uploader)
  end

  it "can upload an acceptable file" do
    post :upload, params: { user: { avatar: file1 } }
    expect(response).to have_http_status(:created)
  end

  it "can not upload an unacceptable file" do
    post :upload, params: { user: { avatar: file2 } }
    expect(response).to have_http_status(:not_acceptable)
  end

  it "will commit previously uploaded files" do
    post :upload, params: { user: { avatar: file1 } }

    json = JSON.parse(response.body)

    # Commit the file upload to the resource
    post :create, params: { user: { commit_avatar: json["uploads"].first } }

    expect(controller.params[:user][:avatar]).to be_a(ActionDispatch::Http::UploadedFile)
    expect(User.last.avatar.file.filename).to eq("1.jpg")
  end

  it "will remove an upload by it's filename" do
    post :upload, params: { user: { avatar: file1 } }

    json = JSON.parse(response.body)

    # Commit the file upload to the resource
    post :create, params: { user: { commit_avatar: json["uploads"].first } }

    # File should exist
    expect(User.last.avatar).to be_present

    patch :update, params: { id: User.last.id, user: { name: "Test", remove_avatar: User.last.avatar.file.filename } }

    # We removed it, file should not exist
    expect(User.last.avatar).to_not be_present
  end

  it "will remove an upload by it's uuid" do
    post :upload, params: { user: { avatar: file1 } }

    json = JSON.parse(response.body)

    # Create the resource, but remove the temp file
    post :create, params: { user: { name: "Test", remove_avatar: json["uploads"].first } }

    expect(User.last.avatar).to_not be_present

  end

end
