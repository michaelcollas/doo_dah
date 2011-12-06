$KCODE = 'U'
require 'zlib'

module DooDah

  class ZipOutputStream

    def initialize(output_stream)
      @output_stream = output_stream
      @total_bytes_written = 0
      @entries = []
    end

    # TODO: take block instead of using a start/end method pair?
    def start_entry(name, size=0)
      end_current_entry
      new_entry = ZipEntry.new(self, name, size)
      @entries << new_entry
      new_entry
    end

    def end_current_entry
      return unless current_entry
      current_entry.close
    end

    def entry_count
      @entries.size
    end

    def close
      end_current_entry
      @central_directory_offset = current_offset
      @entries.each { |entry| entry.write_central_header }
      write_end_of_central_directory
    end

    def current_offset
      @total_bytes_written
    end

    def write(data)
      bytes_written = @output_stream.write(data)
      @total_bytes_written += bytes_written
      bytes_written
    end

    private
    
    attr_reader :central_directory_offset
    include CentralDirectoryHeader
    
    def current_entry
      @entries.last
    end

  end

end

