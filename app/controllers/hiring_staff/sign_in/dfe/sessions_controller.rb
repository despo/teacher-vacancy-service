class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create show new callback]
  skip_before_action :verify_authenticity_token, only: %i[create new]

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end

  def show
    tva_permissions = session[:tva_permissions]
    school_urns = tva_permissions.map { |item| item['school_urn'] }
    @schools = School.where('urn in (?)', school_urns)
    render 'hiring_staff/dfe/sessions/show'
  end

  def create
    return set_selected_school if selected_school_urn
    permissions = authorise

    if permissions.many?
      select_school(permissions)
      redirect_to dfe_path
    elsif permissions.school_urn.present?
      update_session(permissions.school_urn)
      redirect_to school_path
    else
      Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.failure', current_session_id).log_without_association
      redirect_to page_path('user-not-authorised')
    end
  end

  private

  def update_session(school_urn, session_id = oid)
    session.update(session_id: session_id, urn: school_urn)
    Auditor::Audit.new(current_school, 'dfe-sign-in.authorisation.success', current_session_id).log
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def oid
    auth_hash['uid']
  end

  def identifier
    auth_hash['info']['email']
  end

  def set_selected_school
    update_session(selected_school_urn, oid: session[:oid])
    redirect_to school_path
  end

  def selected_school_urn
    params.present? && params['dfe'] ? params.require('dfe').permit('urn')['urn'] : false
  end

  def select_school(permissions)
    Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.select_school', current_session_id).log_without_association
    session.update(provider: 'dfe', tva_permissions: permissions.all_permissions, oid: oid)
  end

  def authorise
    Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', current_session_id).log_without_association
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier)
    permissions
  end
end
