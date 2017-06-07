FactoryGirl.define do
  factory :user do
    name 'Test'

    trait :with_avatar do
      avatar { fixture_file_upload(File.expand_path('../../fixtures/files/1.jpg', __FILE__), 'image/jpeg') }
    end

    trait :with_images do
      images { [fixture_file_upload(File.expand_path('../../fixtures/files/2.jpg', __FILE__), 'image/jpeg'), fixture_file_upload(File.expand_path('../../fixtures/files/3.jpg', __FILE__), 'image/jpeg')] }
    end
  end
end