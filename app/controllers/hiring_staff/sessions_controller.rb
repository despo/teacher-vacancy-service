class HiringStaff::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[new destroy parse_area]

  def new
    # if Rails.env.test? && ENV['SIGN_IN_WITH_DFE'].present? && ENV['SIGN_IN_WITH_DFE'].eql?('true')
    #   redirect_to_dfe_sign_in
    # else
    #   redirect_to_azure
    # end
  end

  def destroy
    session.destroy
    redirect_to root_path, notice: I18n.t('messages.access.signed_out')
  end

  def parse_area
    flash[:notice] = case params[:schoolarea][:name]
                     when 'Cambridgeshire'
                       'Area: Cambridgeshire'
                     when 'The North East'
                       'Area: The North East'
                     when 'Central Bedfordshire'
                       'Area: Central Bedfordshire'
                     when 'Any other area'
                       'Area: Any other area'
                     else
                       '???'
                     end
    redirect_to new_sessions_path
  end

  private def redirect_to_dfe_sign_in
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end

  private def redirect_to_azure
    # Defined by Azure AD strategy: https://github.com/AzureAD/omniauth-azure-activedirectory#usage
    redirect_to '/auth/azureactivedirectory'
  end
end
