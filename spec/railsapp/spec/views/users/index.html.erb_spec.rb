require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    assign(:users, [
      User.create!(
        :avatar => "Avatar",
        :images => ""
      ),
      User.create!(
        :avatar => "Avatar",
        :images => ""
      )
    ])
  end

  it "renders a list of users" do
    render
    assert_select "tr>td", :text => "Avatar".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
