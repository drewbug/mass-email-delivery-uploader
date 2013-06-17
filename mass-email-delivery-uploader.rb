require 'sinatra'

get '/' do
  erb :form
end

post '/upload' do
  filename = params[:file][:filename]
  tempfile = params[:file][:tempfile]

  slice_size = 1

  out_files = IO.foreach(tempfile).each_slice(slice_size).each_with_index.map do |slice, index|
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