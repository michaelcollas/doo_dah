require 'spec_helper'

module DooDah

  describe ZipOutputStream do
  
    before do
      @output_stream = stub(:write => 7)
      @zip = ZipOutputStream.new(@output_stream)
      @entry = stub(:close => nil, :closed? => false)
      ZipEntry.stub(:new => @entry)
    end
    
    describe 'when constructing with a block' do
      
      it 'should yield itself to the block' do
        block_parameter = nil
        zip_output_stream = ZipOutputStream.new(@output_stream) {|output_stream| block_parameter = output_stream }
        block_parameter.should == zip_output_stream
      end
      
      it 'should close itself upon return from the block' do
        zip_output_stream = ZipOutputStream.allocate
        zip_output_stream.should_receive(:close)
        zip_output_stream.send(:initialize, @output_stream) {|output_stream| }
      end
      
      it 'should close itself even if an exception is thrown in the block' do
        zip_output_stream = ZipOutputStream.allocate
        zip_output_stream.should_receive(:close)
        BadStuff = Class.new(Exception)
        begin
          zip_output_stream.send(:initialize, @output_stream) { |output_stream| raise BadStuff }
        rescue BadStuff
        end        
      end
      
    end

    describe '#start_entry' do

      it 'should create a ZipEntry with the zip output stream as its owner' do
        ZipEntry.should_receive(:new).with(@zip, 'entry name', 0, 0)
        @zip.start_entry('entry name')
      end
      
      it 'should create the ZipEntry with 0 size and crc if neither are specified' do
        ZipEntry.should_receive(:new).with(@zip, 'entry name', 0, 0)
        @zip.start_entry('entry name')
      end
      
      it 'should create the ZipEntry with a pre-determined size if specified' do
        ZipEntry.should_receive(:new).with(@zip, 'entry name', 123, 0)
        @zip.start_entry('entry name', 123)
      end
      
      it 'should create the ZipEntry with a pre-determined crc if specified' do
        ZipEntry.should_receive(:new).with(@zip, 'entry name', 0, 9876543210)
        @zip.start_entry('entry name', 0, 9876543210)
      end      

      it 'should return the new entry' do
        @zip.start_entry('entry name', 123).should == @entry
      end

      it 'should ensure that the next most recently created entry is closed' do
        entry1 = @zip.start_entry('first entry', 0)
        entry1.should_receive(:close)
        @zip.start_entry('entry2', 0)
      end

    end

    describe '#create_entry' do

      it 'should create a new ZipEntry' do
        ZipEntry.should_receive(:new).with(@zip, 'entry name', 0, 0)
        @zip.create_entry('entry name') {}
      end

      it 'should yield the new entry to a block' do
       	yielded_zip_entry = nil
        @zip.create_entry('entry name') {|zip_entry| yielded_zip_entry = zip_entry}
        yielded_zip_entry.should == @entry
      end

      it 'should close the new entry on return from the block' do
        @entry.should_receive(:close)
        @zip.create_entry('entry name') {}
      end

      it 'should close the new entry if an exception is raised during execution of the provided block' do
        @entry.should_receive(:close)
        expected_error = Class.new(Exception)
        begin
          @zip.create_entry('entry name') { |zip_entry| raise expected_error } 
        rescue expected_error
        end
      end

      describe 'when there is already a zip entry started but not ended' do
    
        before do
          @zip.start_entry('existing entry')
        end

        it 'should raise an error' do
          lambda { @zip.create_entry('another entry') {} }.should raise_error(ZipOutputStream::EntryOpen)
        end

        it 'should not create a new ZipEntry' do
          ZipEntry.should_not_receive(:new)
          begin
            @zip.create_entry('another entry')
          rescue ZipOutputStream::EntryOpen
          end
        end

      end

    end

    describe '#end_current_entry' do

      it 'should close the most recently created entry' do
        entry = @zip.start_entry('name', 0)
        entry.should_receive(:close)
        @zip.end_current_entry
      end

      it 'should not fail if no entry has been created' do
        lambda { @zip.end_current_entry }.should_not raise_error
      end

    end

    describe '#close' do

      before do
        ZipEntry.stub(:new => stub(:close => nil, :write_central_header => nil))
      end

      it 'should ensure that the most recently started entry is closed' do
        entry = @zip.start_entry('first entry', 0)
        entry.should_receive(:close)
        @zip.close
      end

      it 'should cause each entry created by the zip output stream to write a central directory header' do
        entries = [@zip.start_entry('first', 0), @zip.start_entry('second', 0), @zip.start_entry('third', 0)]
        entries.each { |entry| entry.should_receive(:write_central_header) }
        @zip.close
      end

      it 'should write an end of central directory record' do
        @zip.should_receive(:write_end_of_central_directory)
        @zip.close
      end

      it 'should record the current offset as the start of the central directory before writing central header records' do
        @zip.stub(:current_offset => 789)
        entry = @zip.start_entry('first entry', 0)
        entry.stub(:write_central_header) do
          @zip.send(:central_directory_offset).should == 789
        end
        @zip.close
      end

    end
  
    it 'should have a count of the number of entries it has created' do
      @zip.start_entry('name', 0)
      @zip.start_entry('name', 0)
      @zip.entry_count.should == 2
    end

    it 'should send data unchanged to the output stream when #write() is called' do
      @output_stream.should_receive(:write).with('7 bytes')
      @zip.write('7 bytes')
    end

    it '#current_offset should provide a total count of the number of bytes written' do
      @zip.write('7 bytes')
      @zip.write('7 bytes')
      @zip.current_offset.should == 14
    end
    
    it 'should not close itself when constructed without a block' do
      zip_output_stream = ZipOutputStream.allocate
      zip_output_stream.should_not_receive(:close)
      zip_output_stream.send(:initialize, @output_stream)      
    end

  end

end
