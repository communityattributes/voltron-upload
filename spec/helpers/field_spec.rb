require 'spec_helper'

class Template < ActionView::Base
  extend ActionView::Helpers::FormHelper
end

describe Voltron::Upload::Field do

  let(:user) { FactoryGirl.create(:user) }
  let(:user_avatar) { FactoryGirl.create(:user, :with_avatar) }
  let(:user_images) { FactoryGirl.create(:user, :with_images) }

  let(:template) { Template.new(File.expand_path('../../../app/views', __FILE__)) }

  let(:builder_user) { ActionView::Helpers::FormBuilder.new(:user, user, template, {}) }
  let(:builder_user_avatar) { ActionView::Helpers::FormBuilder.new(:user, user_avatar, template, {}) }
  let(:builder_user_images) { ActionView::Helpers::FormBuilder.new(:user, user_images, template, {}) }

  it 'can generate file upload input markup' do
    field = builder_user.file_field(:avatar)
    expect(field).to include(':files="[]"')
    expect(field).to include(':cached="[]"')
    expect(field).to include(':removed="[]"')
    expect(field).to include(':options="{}"')
  end

  it 'generates default file input markup if default_input' do
    expect(builder_user.file_field(:avatar, default: true)).to eq('<input type="file" name="user[avatar]" id="user_avatar" />')
  end

  it 'uses the provided markup as the preview markup' do
    expect(builder_user.file_field(:avatar, preview: '<div class="special-container"></div>')).to include(':options="{&quot;previewTemplate&quot;:&quot;\\u003cdiv class=\\&quot;special-container\\&quot;\\u003e\\u003c/div\\u003e&quot;}"')
  end

  it 'will not include files flagged for removal' do
    expect(builder_user_avatar.file_field(:avatar)).to include(':removed="[]"')
    user_avatar.remove_avatar = user_avatar.avatar.id
    expect(builder_user_avatar.file_field(:avatar)).to include(":removed=\"[&quot;#{user_avatar.avatar.id}&quot;]\"")

    expect(builder_user_images.file_field(:images)).to include(':removed="[]"')
    user_images.remove_images = [user_images.images.first.id]
    expect(builder_user_images.file_field(:images)).to include(":removed=\"[&quot;#{user_images.images.first.id}&quot;]\"")
  end

  it 'will include the preview template markup if defined preview matches a template' do
    field = builder_user.file_field(:avatar, preview: :progress)
    expect(field).to include('dz-preview')
    expect(field).to include('dz-progress')
    expect(field).to include('dz-error-message')
  end

end
