require_relative 'commit_author'

def create_author_instance(json)
  # If author is null, this user deleted his account, which is why there's no author object for him.
  # Author's e-mail will still be saved to the instance
  login = !json['author'].nil? ? json['author']['login'] : nil
  email = json['commit']['author']['email']
  CommitAuthor.new(login, email)
end