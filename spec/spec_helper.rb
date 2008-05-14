require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../lib/github'

# prevent the use of `` in tests
Spec::Runner.configure do |configuration|
  # load this here so it's covered by the `` guard
  configuration.prepend_before(:all) do
    module GitHub
      load 'helpers.rb'
      load 'commands.rb'
    end
  end

  backtick = nil # establish the variable in this scope
  saved_system = nil
  configuration.prepend_before(:all) do
    # raise an exception if Kernel#` or Kernel#system is used
    # in our tests, we want to ensure we're fully self-contained
    Kernel.instance_eval do
      backtick = instance_method(:`)
      saved_system = instance_method(:system)
      define_method :` do |str|
        raise "Cannot use backticks in tests"
      end
      define_method :system do |*args|
        raise "Cannot use Kernel#system in tests"
      end
    end
  end

  configuration.prepend_after(:all) do
    # and now restore Kernel#` and Kernel#system
    Kernel.instance_eval do
      define_method :`, backtick
      define_method :system, saved_system
    end
  end
end
