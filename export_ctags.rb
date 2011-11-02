#!/usr/bin/env ruby

SMALLWORLD_GIS = 'c:\smallworld\420\product'
mf = [File.join(SMALLWORLD_GIS, 'etc\x86\method_finder.exe')]
image_file = File.join(SMALLWORLD_GIS, 'images\main\swaf.mf')

fail "image file is not present" if not File.exists? image_file
fail "mf file is not present" if not File.exists? mf[0]

def get_stats r, w

  output = []

  w.write "stats\n"

  for i in 0..4 do
    output.push r.readline
  end
  output
end

def our_popen cmd, &blk
  r, w = IO.pipe
  IO.popen cmd + [:in => r] do |read_pipe|
    yield read_pipe, w
  end
end

def bailout write_pipe
  write_pipe.write "quit\n"
  exit
end

our_popen mf do |read_pipe, write_pipe|

  puts get_stats read_pipe, write_pipe

  write_pipe.write "load #{image_file}\n"

  write_pipe.write "stats\n"
  puts get_stats read_pipe, write_pipe

  write_pipe.write "method_cut_off 1000000\n"
  write_pipe.write "override_flags\n"

  write_pipe.write "print_curr_methods\n"
  for i in 0..4 do
    puts r.readline
  end
  bailout write_pipe

  # line = read_pipe.readline
  # line == reset()  IN  sw:xml_output_stream    B
  # line == method iets van whitespace IN object \S
  # last line == number
  methods = parse_output read_pipe

  for method in methods do
    write_pipe.write "pr_source_file #{method_name} #{object}\n"

    source_file = read_pipe.readline
    # maybe parse $SMALLWORLD OR $PROJECT_DIR
    tagsfile.write "#{source_file} #{method_signature} #{method_regex}"
  end

  write_pipe.write "quit\n"

end
