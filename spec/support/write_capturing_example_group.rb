class WriteCapturingExampleGroup < Spec::ExampleGroup

  attr_reader :writer
  attr_reader :written

  before do
    @written = ''
  end

  def record_writes(new_writer)
    @writer = new_writer
    writer.stub(:write) { |new_value| @written << new_value; new_value.size }
  end

end

Spec::Example::ExampleGroupFactory.register(:write_capturing, WriteCapturingExampleGroup)
