require 'json'
require 'date'

TOKEN_FILE = 'access_token.input'

def read_list_commits(input_file)
  commits = []
  File.open(input_file, 'r') do |commit_file|
    commit_file.each_line do |commit_hash|
      commit_hash, commit_url = commit_hash.split(',')
      commits << {
        'hash' => commit_hash.gsub(/\s|"|'/, ''),
        'url' => commit_url.gsub(/\s|"|'/, '')
      }
    end
  end
  commits
end

def get_access_token
  File.open(TOKEN_FILE, 'r').first
end

def write_to_file data
  File.open "logs/log_#{Time.now.to_s.gsub " ", "_" }.json", 'w' do |file|
    file.write JSON.pretty_generate data.map { |o| Hash[o.each_pair.to_a] }
  end
end

def write_hash_to_csv(data, header=false, separator=';', dir='log', filename='logs')
  File.open("logs/#{dir}/#{filename}_#{Time.now.to_s.gsub " ", "_" }.csv", 'w') do |file|
    if header
      file.write("#{data.keys.join(separator)}\n")
    end
    file.write("#{data.values.join(separator)}\n")
  end
end

def write_list_to_csv(data, header=false, separator=';', dir='log', filename='logs')
  File.open("logs/#{dir}/#{filename}_#{Time.now.to_s.gsub " ", "_" }.csv", 'w') do |file|
    if header && data.length > 0
      file.write("#{data[0].keys.join(separator)}\n")
    end
    for d in data
      file.write("#{d.values.join(separator)}\n")
    end
  end
end