class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  def new
    @job_specification_form = JobSpecificationForm.new(school_id: school.id)
    return if session[:current_step].blank?

    @job_specification_form = JobSpecificationForm.new(session[:vacancy_attributes])
    @job_specification_form.valid?
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @job_specification_form = JobSpecificationForm.new(job_specification_form)
    store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact)

    if @job_specification_form.valid?
      vacancy = session_vacancy_id ? update_vacancy(job_specification_form) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact!)

      redirect_to_next_step(vacancy)
    else
      session[:current_step] = :step_1 if session[:current_step].blank?
      redirect_to job_specification_school_job_path(anchor: 'errors')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    vacancy_attributes = source_update? ? session[:vacancy_attributes] : retrieve_job_from_db
    @school = school

    @job_specification_form = JobSpecificationForm.new(vacancy_attributes)
    @job_specification_form.valid?
  end

  # rubocop:disable Metrics/AbcSize
  def update
    vacancy = school.vacancies.published.find(vacancy_id)
    @job_specification_form = JobSpecificationForm.new(job_specification_form)
    @job_specification_form.id = vacancy.id

    if @job_specification_form.valid?
      reset_session_vacancy!
      update_vacancy(job_specification_form, vacancy)
      redirect_to edit_school_job_path(vacancy.id), notice: I18n.t('messages.jobs.updated')
    else
      store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact!)
      redirect_to edit_school_job_job_specification_path(vacancy.id,
                                                         anchor: 'errors',
                                                         source: 'update')
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def job_specification_form
    params.require(:job_specification_form).permit(:job_title, :job_description, :leadership_id,
                                                   :minimum_salary, :maximum_salary, :working_pattern,
                                                   :benefits, :weekly_hours, :subject_id, :min_pay_scale_id,
                                                   :max_pay_scale_id, :starts_on_dd, :starts_on_mm,
                                                   :starts_on_yyyy, :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
                                                   :flexible_working)
  end

  def save_vacancy_without_validation
    @job_specification_form.vacancy.school_id = school.id
    @job_specification_form.vacancy.send :set_slug
    @job_specification_form.vacancy.status = :draft
    Auditor::Audit.new(@job_specification_form.vacancy, 'vacancy.create', current_session_id).log do
      @job_specification_form.vacancy.save(validate: false)
    end
    @job_specification_form.vacancy
  end

  def next_step
    candidate_specification_school_job_path
  end

  def called_from_update_method
    params[:source]&.eql?('update')
  end
end
