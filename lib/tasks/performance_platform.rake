require 'performance_platform'

namespace :performance_platform do
  desc 'Performance Platform transaction submission'
  task submit: :environment do
    Rake::Task['performance_platform:submit_transactions'].invoke
    Rake::Task['performance_platform:submit_user_satisfaction'].invoke
  end

  task submit_transactions: :environment do
    yesteday = Date.current.beginning_of_day - 1.day
    submit_transactions(yesteday)
  end

  task submit_user_satisfaction: :environment do
    yesterday = Date.current.beginning_of_day - 1.day
    submit_feedback(yesterday)
  end

  task submit_data_up_to_today: :environment do
    start_date = Date.parse('20/04/2018')
    current_date = Date.current
    number_of_days = current_date.mjd - start_date.mjd

    while number_of_days.positive?
      date = Date.current.beginning_of_day - number_of_days.day
      submit_transactions(date)
      submit_feedback(date)
      number_of_days -= 1
    end
  end
end

def submit_feedback(date = Date.current.beginning_of_day - 1)
  return if TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).performed?

  data = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
  feedback_counts = Feedback.published_on(date).group(:rating).count
  data.merge!(feedback_counts)

  user_satisfaction = PerformancePlatform::UserSatisfaction.new(PP_USER_SATISFACTION_TOKEN)
  user_satisfaction.submit(data, date.utc.iso8601)

  TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).log_success
rescue StandardError => e
  TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).log_failure
  Rollbar.log(:error,
              'Something went wrong and user satisfaction was not submitted to the Performance Platform',
              e.message)
end

def submit_transactions(date = Date.current.beginning_of_day - 1)
  return if TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).performed?
  no_of_transactions = Vacancy.published_on_count(date)
  performance_platform = PerformancePlatform::TransactionsByChannel.new(PP_TRANSACTIONS_BY_CHANNEL_TOKEN)
  performance_platform.submit_transactions(no_of_transactions, date.utc.iso8601)

  TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).log_success
rescue StandardError => e
  TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).log_failure
  Rollbar.log(:error,
              'Something went wrong and transactions were not submitted to the Performance Platform',
              e.message)
end
