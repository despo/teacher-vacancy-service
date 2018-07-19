class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create callback]
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier)
    Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', current_session_id).log_without_association

    if permissions.school_urn.present?
      update_session(permissions.school_urn)
      redirect_to school_path
    else
      Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.failure', current_session_id).log_without_association
      redirect_to root_path, notice: I18n.t('errors.sign_in.unauthorised')
    end
  end

  private

  def update_session(school_urn)
    session.update(session_id: oid, urn: school_urn)
    Auditor::Audit.new(current_school, 'dfe-sign-in.authorisation.success', current_session_id).log
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def oid
    auth_hash['uid']
  end

  private def identifier
    auth_hash['info']['email']
  end
end
