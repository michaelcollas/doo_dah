module DosTime
  module Formatter

    def to_dos_time
      (sec >> 1) + (min << 5) + (hour << 11)
    end
  
    def to_dos_date
      day + (month << 5) + ((year - 1980) << 9)
    end

  end
end
