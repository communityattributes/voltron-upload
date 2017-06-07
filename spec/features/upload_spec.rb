require 'spec_helper'

feature 'Upload', type: :feature do


  scenario 'User uploads a single file' do
    visit new_user_path

    fill_in 'Name', with: 'Test'

    execute_script("$('#user_avatar_input').css({ visibility: 'visible', height: 100, width: 400 }).removeClass('dz-hidden-input');")
    attach_file('user_avatar_input', File.expand_path('../../fixtures/files/1.jpg', __FILE__), make_visible: true)

    click_button 'Create User'

    expect(page).to have_text('User was successfully created.')
  end

  scenario 'User uploads multiple files' do
    visit new_user_path

    fill_in 'Name', with: 'Test'

    execute_script("$('#user_images_input').css({ visibility: 'visible', height: 100, width: 400 }).removeClass('dz-hidden-input');")
    attach_file('user_images_input', File.expand_path('../../fixtures/files/2.jpg', __FILE__), multiple: true, make_visible: true)

    click_button 'Create User'

    expect(page).to have_text('User was successfully created.')

    expect(User.last.images.first.file.filename).to eq('2.jpg')
  end

  scenario 'User submits files with an invalid form' do
    visit new_user_path

    execute_script("$('#user_avatar_input').css({ visibility: 'visible', height: 100, width: 400 }).removeClass('dz-hidden-input');")
    attach_file('user_avatar_input', File.expand_path('../../fixtures/files/3.jpg', __FILE__), make_visible: true)

    click_button 'Create User'

    expect(page).to have_text('1 error prohibited this user from being saved')

    expect(page).to have_css('#user_avatar_cache', visible: false)
    expect(find('#user_avatar_cache', visible: false).value).to match(/^(-)?[\d]+\-[\d]+(\-[\d]{4})?\-[\d]{4}/)
  end

end