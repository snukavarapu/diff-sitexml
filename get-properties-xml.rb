#!/usr/bin/env ruby
require 'tempfile'

input_path = ARGV[0]
ignore = ['.','..']
temp_files = []
Dir.foreach(input_path) do |each_file|

  # Only go through directories and ignore directories specified by user.
  #unless File.ftype(each_file) != "directory" or ignore.include?(each_file)
  unless ignore.include?(each_file)

    each_file = input_path + each_file
    puts "----" + each_file + "-------\n"

    unless File.exist?(each_file.to_s) 
      STDERR.printf("Input files not provided!\n\n" +
                "Usage: ./bin/get-properties-xml <path>\n")
      exit(-1)
    end 

    lines = File.read(each_file).lines

    keys = lines
      .select{ |l| l.include?('<name>') }
      .map{ |l| l.gsub(/.*>(.*)<.*\n?/, '\\1') }

    unless lines.select{ |l| l.include?('configuration.xsl') }.length > 0
      STDERR.printf("\nWarning: " + each_file +
                  " does not reference configuration.xsl.\n" +
                  "This does not look like a valid *site.xml file!\n\n")
    end 
    temp_file = Tempfile.new('get-properties-xml')

    keys.sort.each do |key|
      temp_file.write("#{key}\n")
    end
    temp_file.close

    pid = spawn('cat', temp_file.path,
            :close_others => false,
            :out => STDOUT,
            :err => STDERR)
    Process.wait(pid)



    temp_files.push(temp_file)

  end
end 
 


