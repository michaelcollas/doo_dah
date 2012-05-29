require 'rubygems'
require 'doo_dah'

z = DooDah::ZipOutputStream.new(STDOUT)

content = "the name of this file is written in simplified Chinese\n"
z.create_entry('这里插入一个聪明的说', content.size) do |e|
  e.write_file_data(content)
end

content = "the name of this file is written in Japanese\n"
z.create_entry('ここに巧妙なことわざを挿入', content.size) do |e|
  e.write_file_data(content)
end

content = "the name of this file is written in Hebrew\n"
z.create_entry('הכנס אומרים חכם פה', content.size) do |e|
  e.write_file_data(content)
end

content = "the name of this file is written in Arabic\n"
z.create_entry('إدراج قائلا ذكي هنا', content.size) do |e|
  e.write_file_data(content)
end

content = "This zip file contains five files (including this one). If the text \n"+
        "encoding has worked correctly, the first file name should be in \n" + 
        "Chinese, the second in Japanese, the third in Hebrew, and the fourth \n" + 
        "in Arabic. Hebrew and Arabic are both right-to-left reading languages, \n" +
        "so some zip programs may present a listing that has the whole row \n" +
        "reversed.\n"
z.create_entry('readme.txt', content.size) do |e|
  e.write_file_data(content)
end

z.close
