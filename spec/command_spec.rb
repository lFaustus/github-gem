require File.dirname(__FILE__) + '/spec_helper'

describe GitHub::Command do
  before(:each) do
    @command = GitHub::Command.new(proc { |x| puts x })
  end

  it "should return a GitHub::Helper" do
    @command.helper.should be_instance_of(GitHub::Helper)
  end

  it "should call successfully" do
    @command.should_receive(:puts).with("test").once
    @command.call("test")
  end

  it "should return options" do
    GitHub.should_receive(:options).with().once.and_return({:ssh => true})
    @command.options.should == {:ssh => true}
  end

  it "should successfully call out to the shell" do
    class_unguard(Open3, :popen3)
    hi = @command.sh("echo hi")
    hi.should == "hi"
    hi.out?.should be(true)
    hi.error?.should be(false)
    hi.command.should == "echo hi"
    bye = @command.sh("echo bye >&2")
    bye.should == "bye"
    bye.out?.should be(false)
    bye.error?.should be(true)
    bye.command.should == "echo bye >&2"
  end

  it "should return the results of a git operation" do
    GitHub::Command::Shell.should_receive(:new).with("git rev-parse master").once.and_return do |*cmds|
      s = mock("GitHub::Commands::Shell")
      s.should_receive(:run).once.and_return("sha1")
      s
    end
    @command.git("rev-parse master").should == "sha1"
  end

  it "should print the results of a git operation" do
    @command.should_receive(:puts).with("sha1").once
    GitHub::Command::Shell.should_receive(:new).with("git rev-parse master").once.and_return do |*cmds|
      s = mock("GitHub::Commands::Shell")
      s.should_receive(:run).once.and_return("sha1")
      s
    end
    @command.pgit("rev-parse master")
  end

  it "should exec a git command" do
    @command.should_receive(:exec).with("git rev-parse master").once
    @command.git_exec "rev-parse master"
  end

  it "should die" do
    @command.should_receive(:puts).once.with("=> message")
    @command.should_receive(:exit!).once
    @command.die "message"
  end
end
