require_relative 'commit_verifier'
require_relative '../files/file_aux'

path = 'input/*.input'

all_commits = []
for filename in Dir.glob(path)
  puts filename

  commit_verifier = CommitVerifier.new(filename)
  # commits = commit_verifier.get_commits
  # for commit in commits
  #   all_commits << commit
  # end

  # author_commits_per_day_week = commit_verifier.author_commits_per_day_week
  # write_list_to_csv(author_commits_per_day_week, true, ';', filename.split('/')[1].split('.')[0], 'author_commits_per_day_week')
  
  # time_period = commit_verifier.inform_time_period
   
  # commit_size = commit_verifier.inform_commit_size

  # time_period['avg additions/removals'] = commit_size
  # write_hash_to_csv(time_period, true, ';', filename.split('/')[1].split('.')[0], 'commit_size')
  
  # commit_verifier.inform_author
  
  # Takes too long to execute
  # Needs to be authenticated
  commits_by_author = commit_verifier.inform_commits_by_author
  write_list_to_csv(commits_by_author, true, ';', filename.split('/')[1].split('.')[0], 'commits_by_author')
  # author_commits_per_month = commit_verifier.inform_author_commits_per_month
  # write_list_to_csv(author_commits_per_month, true, ';', filename.split('/')[1].split('.')[0], 'author_commits_per_month')
  # number_commits_overall = commit_verifier.inform_commits_per_month
  # additions_commits_overall = commit_verifier.inform_additions_per_commit
  # deletions_commits_overall = commit_verifier.inform_deletions_per_commit
  # number_changes = commit_verifier.inform_files_per_commit
  # author_experience = commit_verifier.inform_authors_experience_days_in_project
  # commits_statistics = [number_commits_overall, additions_commits_overall, deletions_commits_overall, number_changes, author_experience]
  # write_list_to_csv(commits_statistics, true, ';', filename.split('/')[1].split('.')[0], 'commits_statistics')
  puts "END of #{filename}"
end

# if all_commits
#   commits_days = commit_verifier.inform_commits_days(all_commits)
#   write_hash_to_csv(commits_days, true, ';')
# end

