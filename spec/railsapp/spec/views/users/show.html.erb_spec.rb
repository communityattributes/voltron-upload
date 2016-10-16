require 'rails_helper'

RSpec.describe "users/show", type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :avatar => "Avatar",
      :images => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Avatar/)
    expect(rendered).to match(//)
  end
end
