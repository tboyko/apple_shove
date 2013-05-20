require 'apple_shove'

describe AppleShove do

  it 'detects an invalid p12' do
    p12 = 'this is an invalid p12'
    expect { AppleShove.try_p12(p12) }.to raise_error
  end

end