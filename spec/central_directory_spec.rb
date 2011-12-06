require 'spec_helper'

module DooDah

  describe CentralDirectoryHeader, :type => :write_capturing do

    before do
      @entry = stub().extend(CentralDirectoryHeader)
      record_writes @entry
    end

    describe '#write_central_header' do

      before do
        @entry.stub(:local_header_offset => 0, :write_signature => nil, :write_common_header => nil, :write_name => nil)
      end

      it 'should write the central directory signature bytes' do
        @entry.should_receive(:write_signature).with(0x02014b50)
        @entry.write_central_header
      end

      it 'should write the zip specification version in version made by as 1.0 at first byte after signature' do
        @entry.write_central_header
        written[0,1].should have_bytes(10)
      end

      it 'should write the attribute compatability as type 3 (unix) in version made by at the second byte after the signature' do
        @entry.write_central_header
        written[1,1].should have_bytes(3)
      end

      it 'should write the common header' do
        @entry.should_receive(:write_common_header)
        @entry.write_central_header
      end

      it 'should write 2 bytes of 0 as file comment length in first  bytes after common header' do
        @entry.write_central_header
        written[2,2].should have_bytes(0, 0)
      end

      it 'should write 2 bytes of 0 as disk number for start of file 2 bytes after common header' do
        @entry.write_central_header
        written[4,2].should have_bytes(0, 0)
      end

      it 'should write 2 bytes of 0 as internal attributes 4 bytes after common header' do
        @entry.write_central_header
        written[6,2].should have_bytes(0, 0)
      end

      it 'should write 4 bytes of attributes for unix file rw-r--r-- 6 bytes after common header' do
        @entry.write_central_header
        written[8, 4].should have_bytes(0x00, 0x00, 0xa4, 0x81)
      end

      it 'should write 4 bytes of offset to the local header record 10 bytes after the common header' do
        @entry.stub(:local_header_offset => 0x98765432)
        @entry.write_central_header
        written[12, 4].should have_bytes(0x32, 0x54, 0x76, 0x98)
      end

      it 'should write the file name' do
        @entry.should_receive(:write_name)
        @entry.write_central_header
      end

    end

    describe '#write_end_of_central_directory' do

      before do
        @entry.stub(:central_directory_offset => 0, :current_offset => 0, :write_signature => nil, :entry_count => 0)
      end

      it 'should write the end of central directory signature' do
        @entry.should_receive(:write_signature).with(0x06054b50)
        @entry.write_end_of_central_directory
      end

      it 'should write the disk number as 0 in the 2 bytes following the signature' do
        @entry.write_end_of_central_directory
        written[0, 2].should have_bytes(0, 0)
      end

      it 'should write 2 bytes of zero as the directory disk number  2 bytes after the signature' do
        @entry.write_end_of_central_directory
        written[2, 2].should have_bytes(0, 0)
      end

      it 'should write 2 bytes of entry count on this disk 4 bytes after the signature' do
        @entry.stub(:entry_count => 0x0123)
        @entry.write_end_of_central_directory
        written[4, 2].should have_bytes(0x23, 0x01)
      end

      it 'should write 2 bytes of entry count on this disk 6 bytes after the signature' do
        @entry.stub(:entry_count => 0x0234)
        @entry.write_end_of_central_directory
        written[6, 2].should have_bytes(0x34, 0x02)
      end

      it 'should write 4 bytes of central directory size 8 bytes after the signature' do
        @entry.stub(:current_offset => 0x98765432, :central_directory_offset => 0x90000000)
        @entry.write_end_of_central_directory
        written[8, 4].should have_bytes(0x32, 0x54, 0x76, 0x08)
      end

      it 'should write 4 bytes of central directory offset 12 bytes after the signature' do
        @entry.stub(:central_directory_offset => 0x13243546)
        @entry.write_end_of_central_directory
        written[12, 4].should have_bytes(0x46, 0x35, 0x24, 0x13)
      end

      it 'should write 2 bytes of zero as the zip file comment length 16 bytes after the signature' do
        @entry.write_end_of_central_directory
        written[16, 2].should have_bytes(0, 0)
      end

    end

  end

end
