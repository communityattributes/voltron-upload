require 'spec_helper'

describe UsersController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:user_avatar) { FactoryGirl.create(:user, :with_avatar) }
  let(:user_images) { FactoryGirl.create(:user, :with_images) }

  let(:file_jpg1) { fixture_file_upload('files/1.jpg', 'image/jpeg') }
  let(:file_jpg2) { fixture_file_upload('files/2.jpg', 'image/jpeg') }
  let(:file_jpg3) { fixture_file_upload('files/3.jpg', 'image/jpeg') }
  let(:file_text) { fixture_file_upload('files/file.txt', 'text/plain') }

  it 'can upload a file' do
    post :upload, params: { user: { avatar: file_jpg1 } }
    expect(response).to have_http_status(:created)
    expect(response_json).to have_key(:uploads)
  end

  it 'will preserve uploads when a model fails to save' do
    avatar_id = upload(:avatar, false, file_jpg1)
    image_ids = upload(:images, true, file_jpg2, file_jpg3)

    post :create, params: { user: { avatar_cache: avatar_id, images_cache: image_ids.to_s } }

    expect(params[:user][:avatar_cache]).to eq(avatar_id)
    expect(params[:user][:images_cache]).to eq(image_ids.to_s)
  end

  it 'will save files to the model when it is saved' do
    avatar_id = upload(:avatar, false, file_jpg1)
    image_ids = upload(:images, true, file_jpg2, file_jpg3)

    expect(user.avatar_before_type_cast).to be_nil
    expect(user.images_before_type_cast).to be_nil

    patch :update, params: { id: user.id, user: { avatar_cache: avatar_id, images_cache: image_ids.to_s } }

    user.reload

    expect(user.avatar_before_type_cast).to eq('1.jpg')
    expect(JSON.parse(user.images_before_type_cast)).to eq(['2.jpg', '3.jpg'])
  end

  it 'will remove files flagged for removal' do
    expect(user_avatar.avatar).to be_present
    patch :update, params: { id: user_avatar.id, user: { remove_avatar: user_avatar.avatar.id } }
    user_avatar.reload
    expect(user_avatar.avatar).to_not be_present

    expect(user_images.images.length).to eq(2)
    patch :update, params: { id: user_images.id, user: { remove_images: user_images.images.sample(1).map(&:id) } }
    user_images.reload
    expect(user_images.images.length).to eq(1)
  end

  it 'should have an id for each file' do
    user_avatar.avatar.cache!

    # Delete the stored file and cached file to force a fallback to the default id, the filename
    FileUtils.rm(user_avatar.avatar.full_store_path)
    FileUtils.rm(Rails.root.join(File.expand_path('../../railsapp/public', __FILE__), user_avatar.avatar.cache_path))

    expect(user_avatar.avatar.id).to eq(user_avatar.avatar.file.filename)
  end

  it 'will respond with an error message if the upload validation failed' do
    post :upload, params: { user: { avatar: file_text } }
    expect(response).to have_http_status(:not_acceptable)
  end

  it 'will reject the upload if the auth token is invalid' do
    ActionController::Base.allow_forgery_protection = true
    post :upload, params: { user: { avatar: file_jpg1 } }

    expect(response_json).to eq({ 'success' => false, 'error' => 'Invalid authenticity token provided' })
    ActionController::Base.allow_forgery_protection = false
  end

end
