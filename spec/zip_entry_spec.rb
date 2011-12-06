require 'spec_helper'

module DooDah

  describe ZipEntry do
  
    before do
      @bytes_per_write = 123
      @zip_stream = stub(:write => @bytes_per_write, :current_offset => 0)
      @zip_entry = ZipEntry.new(@zip_stream, 'file name')
    end
  
    it 'should retain its name' do
      @zip_entry.name.should == 'file name'
    end
  
    it 'should write a local entry header when created' do
      zip_entry = ZipEntry.allocate
      zip_entry.should_receive(:write_local_header)
      zip_entry.send(:initialize, @zip_stream, 'file name')
    end
  
    it 'should write file data through to the zip stream when file data is written' do
      file_contents = 'this is the content of a file added to the zip file'
      @zip_stream.should_receive(:write).with(file_contents)
      @zip_entry.write_file_data(file_contents)
    end
  
    it 'should keep a count of total file data written for the entry' do
      @zip_entry.write_file_data('')
      @zip_entry.write_file_data('')
      @zip_entry.size.should == 2 * @bytes_per_write
    end
  
    it 'should maintain a crc32 for all of the file data written for the entry' do
      @zip_entry.write_file_data "this is part 1 of the file content\n"
      @zip_entry.write_file_data "and this is part 2"
      @zip_entry.crc.should == 2192856224
    end
  
    it 'should write a local entry footer when closed' do
      @zip_entry.should_receive(:write_local_footer)
      @zip_entry.close
    end
  
    describe 'after being closed' do
   
      before do
        @zip_entry.close
      end
  
      it 'should not write a local footer if close is called again' do
        @zip_entry.should_not_receive(:write_zip_footer)
        @zip_entry.close
      end
  
      it 'should raise an error if an attempt is made to write file data' do
        proc { @zip_entry.write_file_data('something irrelevant') }.should raise_error
      end
  
    end
  
  end

end
