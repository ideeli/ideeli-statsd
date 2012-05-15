require 'ideeli/statsd'

describe Ideeli::Statsd::Client, "configure" do
  before do
    Ideeli::Statsd::Client.configure do |conf|
      conf.host       = nil
      conf.port       = nil
      conf.logger     = nil
      conf.yaml_file  = nil
      conf.namespaces = []
    end
  end

  it "should have defaults" do
    Ideeli::Statsd::Client.logger.should be_nil
    Ideeli::Statsd::Client.host.should be_nil
    Ideeli::Statsd::Client.port.should be_nil
    Ideeli::Statsd::Client.yaml_file.should eq('/etc/statsd_config.yaml')
    Ideeli::Statsd::Client.namespaces.should be_empty
  end

  it "can be configured" do
    Ideeli::Statsd::Client.configure do |conf|
      conf.host       = 'host'
      conf.port       = 10
      conf.logger     = 'logger'
      conf.yaml_file  = 'yaml_file'
      conf.namespaces = ['a', 'b']
    end

    Ideeli::Statsd::Client.host.should eq('host')
    Ideeli::Statsd::Client.port.should eq(10)
    Ideeli::Statsd::Client.logger.should eq('logger')
    Ideeli::Statsd::Client.yaml_file.should eq('yaml_file')
    Ideeli::Statsd::Client.namespaces.should include('a')
    Ideeli::Statsd::Client.namespaces.should include('b')
  end

  it "should read from yaml" do
    Ideeli::Statsd::Client.configure do |conf|
      conf.yaml_file = './statsd_config.yaml'
    end

    Ideeli::Statsd::Client.host.should eq('127.0.0.1')
    Ideeli::Statsd::Client.port.should eq(8125)
    Ideeli::Statsd::Client.namespaces.should include("www.host.localhost.ideeli_development")
    Ideeli::Statsd::Client.namespaces.should include("www.app.ideeli_development")
  end
end

describe Ideeli::Statsd::Client do
  before do
    Ideeli::Statsd::Client.configure do |conf|
      conf.yaml_file  = './statsd_config.yaml'
      conf.logger     = nil
      conf.namespaces = []
    end

    @statsd = double("statsd")
    @statsd.stub(:namespace=)

    Ideeli::Statsd::Client.stub(:statsd).and_return(@statsd)
  end

  it "should delegate increment in each namespace" do
    @statsd.should_receive(:increment).with('foo', 10).twice
    Ideeli::Statsd::Client.increment('foo', 10)
  end

  it "should delegate decrement in each namespace" do
    @statsd.should_receive(:decrement).with('foo', 10).twice
    Ideeli::Statsd::Client.decrement('foo', 10)
  end

  it "should delegate count in each namespace" do
    @statsd.should_receive(:count).with('foo', 1, 10).twice
    Ideeli::Statsd::Client.count('foo', 1, 10)
  end

  it "should delegate timing in each namespace" do
    @statsd.should_receive(:timing).with('foo', 100, 10).twice
    Ideeli::Statsd::Client.timing('foo', 100, 10)
  end


  it "should delegate gauge in each namespace" do
    @statsd.should_receive(:gauge).with('foo', 500, 10).twice
    Ideeli::Statsd::Client.gauge('foo', 500, 10)
  end

  it "should delegate time in each namespace but only call the block once" do
    @statsd.should_receive(:timing).twice

    i = 0
    ret = Ideeli::Statsd::Client.time('foo', 10) do
      i += 1
      :retval
    end

    i.should eq(1)
    ret.should eq(:retval)
  end

  it "should use a logger" do
    logger = double("logger")
    logger.should_receive(:error)

    Ideeli::Statsd::Client.configure do |conf|
      conf.logger = logger
    end

    @statsd.stub(:increment).and_raise
    Ideeli::Statsd::Client.increment('foo')
  end

  it "should use handle a nil logger" do
    $stderr.should_receive(:puts)

    @statsd.stub(:increment).and_raise
    Ideeli::Statsd::Client.increment('foo')
  end
end
