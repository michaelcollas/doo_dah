require 'forwardable'

module DooDah

  class ZipEntry
    include LocalDirectoryHeader
    include CentralDirectoryHeader

    attr_reader :size, :crc, :name, :closed
    alias_method :closed?, :closed

    extend ::Forwardable
    def_delegators :@zip_stream, :write, :current_offset

    def initialize(zip_stream, name, size = 0)
      @zip_stream = zip_stream
      @name = name
      @crc = 0
      @size = size
      @closed = false
      write_local_header
    end

    def close
      return if closed
      write_local_footer
      @closed = true
    end

    def write_file_data(data)
      raise 'Zip entry already closed' if closed
      @size += write(data)
      @crc = Zlib::crc32(data, @crc)
    end

    def last_modified_time
      @last_modified_time ||= Time.now.extend(DosTime::Formatter).to_dos_time
    end

    def last_modified_date
      @last_modified_date ||= Time.now.extend(DosTime::Formatter).to_dos_date
    end

    private
    
    attr_accessor :local_header_offset

  end

end
