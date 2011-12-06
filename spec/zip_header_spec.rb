require 'spec_helper'

module DooDah

  describe ZipHeader, :type => :write_capturing do

    it 'should write signature as a four byte little endian unsigned long' do
      header = Object.new.extend(ZipHeader)
      record_writes(header)
      header.write_signature(0x02FD01FE)
      written.should have_bytes(0xFE, 0x01, 0xFD, 0x02)
    end

  end

end
