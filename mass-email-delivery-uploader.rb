require 'rubygems'
require 'sinatra'

get '/' do
  erb :form
end

post '/upload' do
  filename = params[:file][:filename]
  tempfile = params[:file][:tempfile]

  out_files = IO.foreach(tempfile).each_slice(params[:slice_size].to_i).each_with_index.map do |slice, index|
    out_file = "#{File.basename(filename, '.*')}_#{index}.csv"
    File.open(out_file, 'w') { |f| f.puts(slice) }
    out_file
  end

  `screen -d -m -S #{filename}`
  out_files.each do |out_file|
    python_command = "python mymain.py #{out_file} #{out_file}.stat > #{out_file}.stdout 2> #{out_file}.stderr &"
    `screen -S #{filename} -X #{python_command}`
  end
  
  "Success! Files created from #{filename}: #{out_files}"
end

get '/status' do
  status = {}

  Dir.glob('*.csv.stat').each do |fname|
    max = `wc -l #{fname.chomp('.stat')}`.split.first.to_i+1
    complete = `wc -l #{fname}`.split.first.to_i+1

    matches = fname.match(/^(.*)_(\d+).csv.stat$/)

    status[matches[1]] ||= {}
    status[matches[1]][matches[2]] = [ max, complete ]
  end

  erb :status, :locals => {:status => status}
end
