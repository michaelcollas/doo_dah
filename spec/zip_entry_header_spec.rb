require 'spec_helper'

module DooDah

  describe ZipEntryHeader, :type => :write_capturing do

    before do
      @header = stub(:crc => 0, :last_modified_time => 0, :last_modified_date => 0, :size => 0, :name => '')
      @header.extend(ZipEntryHeader)
      record_writes @header
    end

    describe '#write_common_header' do

      it 'should write the version needed to extract in the first 2 bytes' do
        @header.write_common_header
        written[0, 2].should have_bytes(10, 0)
      end

      it 'should write the flag bytes with the UTF8 bit set' do
        @header.write_common_header
        written[3, 1].should have_bytes(0x08)
      end

      it 'should write the flag bytes with the CRC_UNKNOWN bit set if the crc is zero' do
        @header.write_common_header
        written[2, 1].should have_bytes(0x08)
      end

      it 'should write the flag bytes with the CRC_UNKNOWN bit unset if the crc is non-zero' do
        @header.stub(:crc => 1234)
        @header.write_common_header
        written[2, 1].should have_bytes(0x00)
      end

      it 'should write the compression method as STORED' do
        @header.write_common_header
        written[4, 2].should have_bytes(0,0)
      end

      it 'should write the last modified time as a 2 byte long starting at byte 6' do
        @header.stub(:last_modified_time => 0x1234)
        @header.write_common_header
        written[6, 2].should have_bytes(0x34, 0x12)
      end

      it 'should write the last modified date as a 2 byte long starting at byte 8' do
        @header.stub(:last_modified_date => 0x5678)
        @header.write_common_header
        written[8, 2].should have_bytes(0x78, 0x56)
      end

      it 'should write the crc in the four bytes starting at byte 10' do
        @header.stub(:crc => 0x13243546)
        @header.write_common_header
        written[10, 4].should have_bytes(0x46, 0x35, 0x24, 0x13)
      end

      it 'should write the file size in the four bytes starting at byte 14' do
        @header.stub(:size => 0x24354657)
        @header.write_common_header
        written[14, 4].should have_bytes(0x57, 0x46, 0x35, 0x24)
      end

      it 'should write the file size in the four bytes starting at byte 18' do
        @header.stub(:size => 0x31425364)
        @header.write_common_header
        written[18, 4].should have_bytes(0x64, 0x53, 0x42, 0x31)
      end

      it 'should write the byte length of the file name in the two bytes starting at byte 22' do
        multiply_character_string = [0xC3, 0x97].pack('C*')
        multiply_character_string.force_encoding('utf-8') if RUBY_VERSION >= '1.9.0'
        @header.stub(:name => multiply_character_string * 129)
        @header.write_common_header
        written[22, 2].should have_bytes(0x02, 0x01)
      end

      it 'should write 0 as the length of the extra fields in the two bytes starting at byte 24' do
        @header.write_common_header
        written[24, 2].should have_bytes(0, 0)
      end

    end

    describe '#write_name' do

      it 'should write the file name to the output' do
        @header.stub(:name => 'foo')
        @header.write_name
        written.should == 'foo'
      end  

    end

  end

end
