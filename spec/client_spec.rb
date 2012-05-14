require 'ideeli/statsd'

describe Ideeli::Statsd::Client do
  #  [:increment,:decrement,:count,:timing,:time,:guage].each do |meth|

  before do
    Ideeli::Statsd::Options.configure do |conf|
      conf.yaml_file  = './statsd_config.yaml'
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

  it "should delegate time in each namespace" do
    # TODO: should_yield
    @statsd.should_receive(:time).with('foo', 10).twice
    Ideeli::Statsd::Client.time('foo', 10)
  end

  it "should delegate guage in each namespace" do
    @statsd.should_receive(:guage).with('foo', 500, 10).twice
    Ideeli::Statsd::Client.guage('foo', 500, 10)
  end
end
