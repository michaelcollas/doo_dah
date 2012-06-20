module DooDah

  module LittleEndianByteWriter

    def write_byte(value)
      write([value].pack('C'))
    end

    alias_method :write_u8, :write_byte
   
    def write_word(value)
      write([value].pack('v'))
    end

    alias_method :write_u16, :write_word
   
    def write_dword(value)
      write([value].pack('V'))
    end

    alias_method :write_u32, :write_dword

  end

  module ZipHeader
    
    def self.signature_size
      4
    end
    
    def write_signature(signature)
      write([signature].pack('V'))
    end
    
  end

  module ZipEntryHeader
    include ZipHeader

    STORED = 0
    DEFLATED = 8
    LOCAL_ENTRY_HEADER_SIGNATURE = 0x04034b50
    CENTRAL_ENTRY_HEADER_SIGNATURE = 0x02014b50
    END_CENTRAL_DIRECTORY_SIGNATURE = 0x06054b50
    LOCAL_ENTRY_FOOTER_SIGNATURE = 0x08074b50
    LOCAL_ENTRY_STATIC_HEADER_LENGTH = 30
    LOCAL_ENTRY_TRAILING_DESCRIPTOR_LENGTH = 4+4+4
    VERSION_NEEDED_TO_EXTRACT = 10
    GP_FLAGS_CRC_UNKNOWN = 0x0008
    GP_FLAGS_UTF8 = 0x0800
    
    def self.common_header_size
      14 + 12
    end
    
    def self.name_size(name)
      name.length
    end

    def write_common_header()
      flags = GP_FLAGS_UTF8
      flags |= GP_FLAGS_CRC_UNKNOWN if crc.zero?
      write([
        VERSION_NEEDED_TO_EXTRACT, # version needed to extract
        flags,
        STORED,
        last_modified_time,
        last_modified_date,
        crc,
        size,                      # compressed_size = size (stored)
        size,
        name ? name.length : 0,
        0                          # extra length
      ].pack('vvvvvVVVvv'))
    end

    def write_name
      write name
    end

    def write_infozip_utf8_name
      [0x7075, name.size + 5, 1, file-name-crc].pack('vvCV')
    end

  end

  module LocalDirectoryHeader
    include ZipEntryHeader
    
    def self.local_header_size(name)
      ZipHeader.signature_size + ZipEntryHeader.common_header_size + ZipEntryHeader.name_size(name)
    end
    
    def self.local_footer_size
      ZipHeader.signature_size + 12
    end

    def write_local_header
      self.local_header_offset = current_offset
      write_signature(LOCAL_ENTRY_HEADER_SIGNATURE)
      write_common_header
      write_name
    end

    def write_local_footer
      write_signature(LOCAL_ENTRY_FOOTER_SIGNATURE)
      write([crc, size, size].pack('VVV'))
    end

  end

  module CentralDirectoryHeader
    include ZipEntryHeader
    
    def self.central_header_size(name)
      ZipHeader.signature_size + version_made_by_size + ZipEntryHeader.common_header_size + 6 + 8 + ZipEntryHeader.name_size(name) 
    end
    
    def self.end_of_central_directory_size
      ZipHeader.signature_size + 10 + 8
    end
    
    def self.version_made_by_size
      2
    end

    def write_central_header
      write_signature(CENTRAL_ENTRY_HEADER_SIGNATURE)
      write_version_made_by
      write_common_header
      write([
        0,                         # file comment length
        0,                         # start of file disk number
        0,                         # internal attributes = binary
        (010 << 12 | 0644) << 16,  # external attributes = file, rw-r--r--
        local_header_offset
      ].pack('vvvVV'))
      write_name
    end

    def write_end_of_central_directory
      central_directory_size = current_offset - central_directory_offset
      write_signature(END_CENTRAL_DIRECTORY_SIGNATURE)
      end_of_central_directory = [ 
        0,                               # disk number
        0,                               # disk with directory
        entry_count,                   # entries on this disk
        entry_count,                   # total entries
        central_directory_size,
        central_directory_offset,
        0                                # zip file comment length
      ].pack('vvvvVVv')
      write(end_of_central_directory)
    end

    def write_version_made_by
      write([10, 3].pack('CC'))         # version, file system type
    end

  end

end
