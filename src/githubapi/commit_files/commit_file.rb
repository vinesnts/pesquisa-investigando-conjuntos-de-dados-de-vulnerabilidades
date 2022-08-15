class CommitFile

  attr_reader :file_name, :status, :num_additions, :num_deletions, :patch

  def initialize(filename, status, additions, deletions, patch)
    @file_name = filename
    @status = status
    @num_additions = additions
    @num_deletions = deletions
    @patch = patch
  end

  def num_changes
    @num_additions + @num_deletions
  end
end