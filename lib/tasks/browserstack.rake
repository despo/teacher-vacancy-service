CONFIG = YAML.safe_load(File.read(File.join(File.dirname(__FILE__), '../../config/browserstack.yml')))

namespace :browserstack do
  RSpec::Core::RakeTask.new(:local) do |t|
    ENV['TEST_BROWSER'] = 'browserstack'
    t.pattern = Dir.glob('spec/features/**/*_spec.rb')
    t.rspec_opts = '--format documentation --tag browserstack'
    t.verbose = false
  end

  RSpec::Core::RakeTask.new(:all) do |t|
    next if ENV['BROWSERSTACK_USERNAME'].blank?
    puts "Running browserstack for: #{ENV['task_id']}"
    Rake::Task['browserstack:local'].execute
  end

  task default: :local
end
