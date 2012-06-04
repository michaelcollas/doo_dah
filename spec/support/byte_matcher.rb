RSpec::Matchers.define :bytes do |*expected|

  match do |actual|
    @start_byte ||= 0
    actual.bytes.to_a[@start_byte, expected.length] == expected
  end

  chain :at do |start_byte|
    @start_byte = start_byte
  end

  failure_message_for_should do |actual|
    actual_bytes = actual.bytes.to_a.collect {|b| "0x%02x" % b }.join(',')
    "expected #{expected_bytes_description} to be #{actual_bytes}"
  end

  description do
    "#{expected_bytes_description} starting at byte #{@start_byte}"
  end

  def expected_bytes_description
    expected.collect {|b| "0x%02x" % b }.join(',')
  end

end

module RSpec::Matchers
  alias_method(:have_bytes, :bytes)
end
