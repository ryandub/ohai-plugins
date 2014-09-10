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
      if ENV['TRAVIS_PULL_REQUEST'] != 'false'
        puts('Pull Request Testing Disabled.')
        run_kitchen = false
        ENV['OHAI_PLUGINS_PR'] = ENV['TRAVIS_PULL_REQUEST']
      end
    end

    if run_kitchen
      test_platform = ENV['KITCHEN_INSTANCE']
      tests = []
      Kitchen.logger = Kitchen.default_file_logger
      @loader = Kitchen::Loader::YAML.new(project_config: './.kitchen.yml')
      config = Kitchen::Config.new(loader: @loader)
      if test_platform
        config.instances.each do |instance|
          tests << instance if instance.name.include?(test_platform)
        end
        tests.each do |test|
          test.test(:always)
        end
      else
        config.instances.each do |instance|
          instance.test(:always)
        end
      end
    end
  end
end

desc 'Run all tests on Travis'
task travis: ['style', 'integration:cloud']

# Default
task default: ['style', 'integration:vagrant']
