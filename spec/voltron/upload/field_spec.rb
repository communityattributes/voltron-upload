require "rails_helper"

class Template
  extend ActionView::Helpers::FormHelper
end

describe Voltron::Upload::Field do

  let(:builder) { ActionView::Helpers::FormBuilder.new(:user, User.new, Template, {}) }

  it "can generate file upload input markup" do
    expect(builder.file_field(:avatar)).to eq("<input data-files=\"[]\" data-commit=\"[]\" data-upload=\"/users/upload\" type=\"file\" name=\"user[avatar]\" id=\"user_avatar\" />")
  end

  it "generates default file input markup if default_input" do
    expect(builder.file_field(:avatar, default_input: true)).to eq("<input type=\"file\" name=\"user[avatar]\" id=\"user_avatar\" />")
  end

end
