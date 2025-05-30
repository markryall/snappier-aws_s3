# frozen_string_literal: true

require_relative "lib/snappier/aws_s3/version"

Gem::Specification.new do |spec|
  spec.name = "snappier-aws_s3"
  spec.version = Snappier::AwsS3::VERSION
  spec.authors = ["Mark Ryall"]
  spec.email = ["mark@ryall.name"]

  spec.summary = "Persistence mechanism for AWS S3 for snappier gem"
  spec.homepage = "https://github.com/markryall/snappier-aws_s3"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "snappier"

  spec.metadata["rubygems_mfa_required"] = "true"
end
