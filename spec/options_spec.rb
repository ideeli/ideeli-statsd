require 'ideeli/statsd'

describe Ideeli::Statsd::Options do
  it "should have defaults" do
    Ideeli::Statsd::Options.configure

    Ideeli::Statsd::Options.yaml_file.should eq('/etc/statsd_config.yaml')
    Ideeli::Statsd::Options.namespaces.should include('host') # other components nil
    Ideeli::Statsd::Options.namespaces.should include('app')  # other components nil
  end

  it "can be configured" do
    Ideeli::Statsd::Options.configure do |conf|
      conf.logger     = 'logger'
      conf.yaml_file  = 'yaml_file'
      conf.namespaces = ['a', 'b']
    end

    Ideeli::Statsd::Options.logger.should eq('logger')
    Ideeli::Statsd::Options.yaml_file.should eq('yaml_file')
    Ideeli::Statsd::Options.namespaces.should include('a')
    Ideeli::Statsd::Options.namespaces.should include('b')
  end

  it "should read from yaml" do
    Ideeli::Statsd::Options.configure do |conf|
      conf.yaml_file = './statsd_config.yaml'
    end

    Ideeli::Statsd::Options.node_type.should eq('www')
    Ideeli::Statsd::Options.application.should eq('ideeli_development')
    Ideeli::Statsd::Options.fqdn.should eq('localhost')
    Ideeli::Statsd::Options.host.should eq('127.0.0.1')
    Ideeli::Statsd::Options.port.should eq(8125)
  end
end
