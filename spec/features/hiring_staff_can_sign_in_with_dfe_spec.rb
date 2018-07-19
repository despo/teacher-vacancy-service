require 'rails_helper'
RSpec.feature 'Hiring staff can sign in with DfE Sign In' do
  before do
    OmniAuth.config.test_mode = true
    ENV['SIGN_IN_WITH_DFE'] = 'true'
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
    ENV['SIGN_IN_WITH_DFE'] = 'false'
  end

  let!(:school) { create(:school, urn: '110627') }

  scenario 'with valid credentials that do match a school', elasticsearch: true do
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      provider: 'dfe',
      uid: 'an-email@exmple.com',
      info: {
        email: 'an-email@example.com',
      }
    )

    mock_response = double(body: {
      user:
      {
        permissions:
        [
          {
            user_token: 'an-email@example.com',
            school_urn: '110627'
          }
        ]
      }
    }.to_json)

    expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
      .and_return(AuthHelpers::MockPermissions.new(mock_response))

    visit root_path

    click_on(I18n.t('nav.sign_in'))
    choose(HiringStaff::IdentificationsController::DFE_SIGN_IN_OPTIONS.first.to_radio.last)
    click_on(I18n.t('sign_in.link'))

    expect(page).to have_content("Jobs at #{school.name}")
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.sign_out')) }
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
  end

  scenario 'with valid credentials that do not match a school', elasticsearch: true do
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      provider: 'dfe',
      uid: 'an-unknown-oid',
      info: {
        email: 'an-email@example.com',
      }
    )
    mock_response = double(body: { user: { permissions: [] } }.to_json)
    expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
      .and_return(AuthHelpers::MockPermissions.new(mock_response))
    visit root_path

    click_on(I18n.t('nav.sign_in'))
    choose(HiringStaff::IdentificationsController::DFE_SIGN_IN_OPTIONS.first.to_radio.last)
    click_on(I18n.t('sign_in.link'))

    expect(page).to have_content(I18n.t('errors.sign_in.unauthorised'))
    within('#proposition-links') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
  end
end
