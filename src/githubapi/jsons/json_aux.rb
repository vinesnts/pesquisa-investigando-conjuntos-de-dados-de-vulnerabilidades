require 'net/http'
require 'json'
require_relative '../commits/commit'
require_relative '../files/file_aux'

$commits_url = "https://api.github.com/repos/chromium/chromium/commits"

def get_authorization()
  access_token = get_access_token.split('=')
  if access_token && access_token[0] == 'access_token'
    authorization = access_token[1]
  end

  authorization 
end

def get_json(resource)
  uri = URI.parse resource
  headers = {
    "Authorization" => "token #{get_authorization}"
  }

  http = Net::HTTP.new uri.host, uri.port
  http.use_ssl = true

  request = Net::HTTP::Get.new uri.to_s, initheader=headers
  response = http.request request

  response.body
end

def repo_commit_by_hash(commit_hash)
  url = commit_hash['url'] + "/#{commit_hash['hash']}"

  json_string = get_json(url)
  begin
    data = JSON.parse(json_string)
    if data.key?('commit')
      data
    elsif data.key?('message') && data['message'].downcase == 'moved permanently'
      json_string = get_json(data['url'])
      data = JSON.parse(json_string)
    end
  rescue
    data = {"message" => 'Error'}
  ensure
    return data
  end
end

def repo_commits_by_author(commit_author, page = 1, interval = nil, url = nil)
  url = (url ? url : $commits_url)
  url = url + "?author=#{commit_author}"

  if interval.key?('from') && interval['from']
    url += "&since=#{interval['from']}"
  end

  if interval.key?('to') && interval['to']
    url += "&until=#{interval['to']}"
  end

  if page
    url += "&page=#{page}"
  end

  url += '&per_page=100'

  json_string = get_json(url)
  JSON.parse(json_string)
end