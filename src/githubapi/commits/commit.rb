class Commit

  attr_reader :hash, :message, :num_comments, :commit_date, :num_additions, :num_deletions, :author, :changed_files, :url

  def initialize(hash, message, num_comments, commit_date, num_additions, num_deletions, author, changed_files, url)
    @hash = hash
    @message = message
    @num_comments = num_comments
    @commit_date = commit_date
    @num_additions = num_additions
    @num_deletions = num_deletions
    @author = author
    @changed_files = changed_files
    @url = url
  end

  def total_number_changes
    @num_additions + @num_deletions
  end
end