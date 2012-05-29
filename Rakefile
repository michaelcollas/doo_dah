require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "zippy"
    gem.summary = 'Creates zip files suitable for streaming.'
    gem.description = <<-END_DESCRIPTION
      This gem creates zip files using the STORE method - i.e. with no compression. This enables the generation of
      zip files with a known size from streamed data, providing the size of the input files is known. 
    END_DESCRIPTION
    gem.email = "mcollas@yahoo.com"
    gem.homepage = "http://github.com/michaelcollas/zippy"
    gem.authors = ["Michael Collas"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "reek", ">= 1.2.8"
    gem.add_development_dependency "sexp_processor", ">= 3.0.4"
    gem.files.exclude('.gitignore')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts << '-T' << '-i' << 'lib\/doo_dah' << '-x' << 'spec\/'
end

task :spec => :check_dependencies

begin
  require 'reek/rake/task'
  Reek::Rake::Task.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
    t.reek_opts << ' --quiet'
    t.ruby_opts << '-r' << 'rubygems' 
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "zippy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
