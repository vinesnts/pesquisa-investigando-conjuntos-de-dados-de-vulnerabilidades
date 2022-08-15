require_relative 'commit_file'

def create_commit_files(json)
   commit_files = []
   json_files = json['files']
   for json_file in json_files
     filename = json_file['filename']
     status = json_file['status']
     additions = json_file['additions']
     deletions = json_file['deletions']
     patch = json_file['patch']
     commit_files << CommitFile.new(filename, status, additions, deletions, patch)
   end
   commit_files
 end