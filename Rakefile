require 'rubocop/rake_task'
require 'kitchen'

# Style tests.
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)
end

desc 'Run style checks'
task style: ['style:ruby']

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'Run Test Kitchen with cloud plugins'
  task :cloud do
    run_kitchen = true
    if ENV['TRAVIS'] == 'true'
      ENV['OHAI_PLUGINS_VERSION'] = ENV['TRAVIS_COMMIT']
    end
    if ENV['TRAVIS_PULL_REQUEST'] != 'false'
      run_kitchen = false
      ENV['OHAI_PLUGINS_PR'] = ENV['TRAVIS_PULL_REQUEST']
    end

    if run_kitchen
      Kitchen.logger = Kitchen.default_file_logger
      @loader = Kitchen::Loader::YAML.new(project_config: './.kitchen.rackspace.yml')
      config = Kitchen::Config.new(loader: @loader)
      config.instances.each do |instance|
        instance.test(:always)
      end
    end
  end
end

desc 'Run all tests on Travis'
task travis: ['style', 'integration:cloud']

# Default
task default: ['style', 'integration:vagrant']
