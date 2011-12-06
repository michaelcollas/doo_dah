require 'spec_helper'

describe DosTime::Formatter do

  def dos_time(time)
    time.extend(DosTime::Formatter)
  end

  describe '#to_dos_date' do

    before do
      @sample_dos_date = dos_time(Time.local(2011, 11, 14)).to_dos_date
    end

    it 'should have the day number in the lowest 5 bits' do
      (@sample_dos_date & 0x1f).should == 14
    end

    it 'should have the month number in the four bits starting at bit 5' do
      (@sample_dos_date >> 5 & 0x0f).should == 11
    end

    it 'should the have the year as an offset from 1980 in the 7 bits starting at bit 9' do
      (@sample_dos_date >> 9 & 0x7f).should == 2011 - 1980
    end

  end

  describe '#to_dos_time' do

    before do
      @sample_dos_time = dos_time(Time.local(2011, 11, 14, 18, 58, 37)).to_dos_time
    end

    it 'should have half the second number in the lowest 5 bits' do
      (@sample_dos_time & 0x1f).should == 37.div(2)
    end

    it 'should have the minute number in the six bits starting at bit 5' do
      (@sample_dos_time >> 5 & 0x3f).should == 58
    end

    it 'should the have the hour number in the 5 bits starting at bit 11' do
      (@sample_dos_time >> 11 & 0x1f).should == 18
    end

  end

end

