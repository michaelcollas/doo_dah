module WriteCapturing

  attr_reader :writer
  attr_reader :written

  def self.included(target)
    target.before do
      @written = ''
    end
  end

  def record_writes(new_writer)
    @writer = new_writer
    writer.stub(:write) { |new_value| @written << new_value; new_value.size }
  end

end

RSpec.configure do |configuration|
  configuration.include(WriteCapturing, :type => :write_capturing)
end

