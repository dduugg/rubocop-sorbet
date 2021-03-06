# frozen_string_literal: true

require('bundler/gem_tasks')

Dir['tasks/**/*.rake'].each { |t| load t }

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task(default: %i[
  documentation_syntax_check
  generate_cops_documentation
  spec
])

desc('Generate a new cop with a template')
task :new_cop, [:cop] do |_task, args|
  require 'rubocop'

  cop_name = args.fetch(:cop) do
    warn 'usage: bundle exec rake new_cop[Department/Name]'
    exit!
  end

  github_user = %x(git config github.user).chop
  github_user = 'Shopify' if github_user.empty?

  generator = RuboCop::Cop::Generator.new(cop_name, github_user)

  generator.write_source
  generator.write_spec
  generator.inject_require(root_file_path: 'lib/rubocop/cop/sorbet_cops.rb')
  generator.inject_config(config_file_path: 'config/default.yml')

  puts generator.todo
end
