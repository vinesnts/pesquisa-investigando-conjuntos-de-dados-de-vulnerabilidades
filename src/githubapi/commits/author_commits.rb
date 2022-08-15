class AuthorCommits

  def initialize(commit_author, interval, url)
    @commits = []
    get_author_commits(commit_author, interval, url)
  end

  def get_commits
    @commits
  end

  def number_of_commits
    @commits.length
  end

  private
  
  # Gets all commits from an author's e-mail in the project defined in json_aux.rb between the time period
  # Interval needs to be a hash with 'from' and 'to' keys, both can be nil to get all commits
  def get_author_commits(commit_author, interval, url)
    page = 1
    next_page = true
    while next_page do
      json = repo_commits_by_author(commit_author.email, page, interval, url)

      if json.length < 100
        next_page = false
      else
        page += 1
      end

      begin
        for commit in json
          commit_hash = commit['sha']
          message = commit['message']
          num_comments = commit['comment_count']
          commit_date = commit['commit']['author']['date']
          num_additions = commit['stats'] ? commit['stats']['additions'] : nil
          num_deletions = commit['stats'] ? commit['stats']['deletions'] : nil
          changed_files = nil
          @commits << Commit.new(commit_hash, message, num_comments, commit_date, num_additions, num_deletions, commit_author, changed_files, url)
        end
      rescue TypeError
        break
      end
    end
  end

end