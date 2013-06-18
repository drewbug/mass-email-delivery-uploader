require 'rubygems'
require 'sinatra'

secret_path="stopwatchingus_uploader_123"

configure do
  $directory = ARGV.any? ? ARGV[0] : '/tmp'
end

get '/' + secret_path + '/' do
  erb :form
end

post '/' + secret_path + '/upload' do
  filename = params[:file][:filename]
  tempfile = params[:file][:tempfile]

  out_files = tempfile.each.each_slice(params[:slice_size].to_i).each_with_index.map do |slice, index|
    out_file = "#{File.basename(filename, '.*')}_#{index}.csv"
    Dir.chdir($directory) { File.open(out_file, 'w') { |f| f.puts(slice) } }
    out_file
  end

  curr_path = File.expand_path(File.dirname(__FILE__))

  out_files.each do |out_file|
    `python #{curr_path}/script_caller.py \"#{$directory}/#{out_file}\" \"#{$directory}/#{out_file}.stat\" > #{out_file}.stdout 2> #{out_file}.stderr &`
  end
  
  "Success! Files created from #{filename}: #{out_files}<br><a href='.'>Click here to return to the main screen</a><br>Please give this a minute or two to launch the processes"
end

get '/' + secret_path + '/status' do
  status = {}
  Dir.glob($directory + '/*.csv.stat').each do |fname|
    max = `wc -l "#{fname.chomp('.stat')}"`.split.first.to_i+1
    complete = `wc -l "#{fname}"`.split.first.to_i+1

    matches = fname.match(/(.*)_(\d+).csv.stat$/)

    status[matches[1]] ||= {}
    status[matches[1]][matches[2]] = [ max, complete ]
  end

  erb :status, :locals => {:status => status}
end
