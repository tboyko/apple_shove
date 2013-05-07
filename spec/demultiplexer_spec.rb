require 'apple_shove'

describe AppleShove::Demultiplexer do

  it 'initializes without error' do
    dmp = AppleShove::Demultiplexer.new max_apns_connections: 10
    dmp.should be_an_instance_of(AppleShove::Demultiplexer)
  end

  it 'raises an error when a connection limit is omitted' do
    expect { AppleShove::Demultiplexer.new }.to raise_error
  end

end