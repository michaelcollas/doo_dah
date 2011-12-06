require 'spec_helper'

module DooDah
  
  describe LocalDirectoryHeader, :type => :write_capturing do
  
    before do
      @entry = Object.new.extend(LocalDirectoryHeader)
    end
  
    describe '#write_local_header' do

      before do
        @entry.stub(:current_offset => 0, :local_header_offset= => nil, :write_signature => nil, :write_common_header => nil, :write_name => nil)
      end
  
      it 'should write a local directory entry signature' do
        @entry.should_receive(:write_signature).with(0x04034b50)
        @entry.write_local_header
      end
  
      it 'should write a common header' do
        @entry.should_receive(:write_common_header)
        @entry.write_local_header
      end
  
      it 'should write the file name' do
        @entry.should_receive(:write_name)
        @entry.write_local_header
      end
  
      it 'should capture the current output stream position' do
        @entry.stub(:current_offset => 1234)
        @entry.should_receive(:local_header_offset=).with(1234)
        @entry.write_local_header
      end
 
    end
  
    describe '#write_local_footer' do

      before do
        @entry.stub(:write_signature => nil, :crc => 0, :size => 0)
        record_writes(@entry)
      end
    
      it 'should write a local directory entry footer' do
        @entry.should_receive(:write_signature).with(0x08074b50)
        @entry.write_local_footer
      end

      it 'should write the crc value in the four bytes after the signature' do
        @entry.stub(:crc => 0x1234)
        @entry.write_local_footer
        written[0, 4].should have_bytes(0x34, 0x12)
      end

      it 'should write the uncompressed file size in the four bytes starting at byte 4 after the signature' do
        @entry.stub(:size => 0x5678)
        @entry.write_local_footer
        written[4, 4].should have_bytes(0x78, 0x56)
      end

      it 'should write the compressed file size in the four bytes starting at byte 8 after the signature' do
        @entry.stub(:size => 0x1324)
        @entry.write_local_footer
        written[8, 4].should have_bytes(0x24, 0x13)
      end

    end
  
  end

end
