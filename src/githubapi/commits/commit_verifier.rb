require_relative '../jsons/json_aux'
require_relative '../files/file_aux'
require_relative '../authors/author_verifier'
require_relative '../commit_files/commit_file_verifier'
require_relative 'author_commits'
require 'date'

class CommitVerifier

  def initialize(input_file)
    @commits = []
    @author_commits = []
    commit_hashes = read_list_commits(input_file)
    for commit_hash in commit_hashes
      @commits << create_commit_instance(commit_hash)
    end
  end

  def get_commits
    @commits
  end

  def inform_time_period()
    dates = get_commit_dates
    ordered_dates = dates.sort
    initial_date = Date.parse(ordered_dates.first)
    final_date = Date.parse(ordered_dates.last)
    puts "The time period from the first to the last is: #{initial_date} - #{final_date}"
    puts "Total number of days is #{(final_date - initial_date).to_i}"

    i = {
      "first commit" => initial_date,
      "last commit" => final_date,
      "number of days" => (final_date - initial_date).to_i,
    }
  end

  # Counts the number of commits from each author for each day of the week
  def author_commits_per_day_week()
    author_commits_per_day_week = []
    for commit in @commits
      if commit.author != nil
        author_commits = AuthorCommits.new(commit.author, {
          "from" => nil,
          "to" => commit.commit_date
        }, commit.url)

        author_commits_per_day_week.append(
          inform_commits_days(author_commits.get_commits, commit.author.email))
      end
    end
    author_commits_per_day_week
  end

  # Counts the number of commits for each day of the week
  def inform_commits_days(commits = nil, author = false)
    dates = get_commit_dates(commits)
    days = {}

    if author
      days['author'] = author
    end

    for date_str in dates
      date = Date.parse(date_str)
      day = date.strftime('%A')
      if days.key?(day)
        days[day] += 1
      else
        days[day] = 1
      end
    end
    days
    # days = days.sort_by {|k, v| -v}
    # days_hash_array = {}
    # for day, n in days
    #   days_hash_array[day] = n
    # end
    # days_hash_array
  end

  def inform_commit_size
    sizes = get_commit_sizes
    mean = sizes.inject(0, :+).to_f / sizes.size
    puts "The average number of lines added or deleted is: #{mean}"
    mean
  end

  def inform_author
    for commit in @commits
      author = commit.author
      if author.login.nil?
        puts("The commit with hash #{commit.hash} has no author, but its e-mail is #{commit.author.email}")
      else
        puts("The commit with hash #{commit.hash} has the author with login #{author.login} and email #{author.email}")
      end
    end
  end

  def inform_files
    for commit in @commits
      changed_files = commit.changed_files
      #TODO da pra fazer uns calculos interessantes
    end
  end

  # Counts the number of commits of the author before each commit in @commits
  # Takes too long to execute since it needs to request 100 by 100 commits
  # Saves author commits to instance
  def inform_commits_by_author
    result = []
    for commit in @commits
      if commit.author != nil
        author_commits = AuthorCommits.new(commit.author, {
          "from" => nil,
          "to" => commit.commit_date
        }, commit.url)
        
        @author_commits << {
          'author' => commit.author,
          'commits' => author_commits.get_commits,
        }
        result.append({
          'hash' => commit.hash,
          'number of commits' => author_commits.number_of_commits,
          'author' => commit.author.email
        })
        puts "Author with e-mail #{commit.author.email} has #{author_commits.number_of_commits} commits before CVE was introduced"
      end
    end
    return result
  end

  # Shows the number of commits of each author from the commits
  # Needs to be called after inform_commits_by_author function
  def inform_author_commits_per_month
    n_commits_month = {}
    if @author_commits.length == 0
      puts "No authors commits where found, did you call inform_commits_by_author function?"
      return
    end

    result = []
    for row in @author_commits
      n_commits_month = n_commits_month(row['commits'])
      sum = 0
      
      puts "Author with e-mail #{row['author'].email} commits frequency in the project before CVE was introduced"
      for year_key, year in n_commits_month
        for month_key, month in year
          sum += month
          puts "year: #{year_key}, month: #{month_key}, commits: #{month}"
        end
      end

      average = sum.to_f / (n_commits_month.length * 12).to_f
      puts "with an average of #{average} commits per month"
      
      min, max, median, first_quartis, third_quartis, average, deviation = get_statistics_per_year(n_commits_month)
      for year_key, year in min
        puts "statistics in the year: #{year_key}"
        puts "average: #{average[year_key]}"
        puts "minimum: #{min[year_key]}"
        puts "maximum: #{max[year_key]}"
        puts "median: #{median[year_key]}"
        puts "first quartis: #{first_quartis[year_key]}"
        puts "third quartis: #{third_quartis[year_key]}"
        puts "deviation: #{deviation[year_key]}"
        puts "END of statistics in the year: #{year_key}"
        result.append({
          "year" => year_key,
          "author" => row['author'].email,
          "total commits" => sum,
          "average" => average[year_key],
          "minimum" => min[year_key],
          "maximum" => max[year_key],
          "median" => median[year_key],
          "first quartis" => first_quartis[year_key],
          "third quartis" => third_quartis[year_key],
          "deviation" => deviation[year_key]
        })
      end

      puts "END of commits frequency of author with e-mail #{row['author'].email}"
    end
    return result
  end

  def inform_commits_per_month
    if @author_commits.length == 0
      puts "No authors commits where found, did you call inform_commits_by_author function?"
      return
    end

    n_commits = n_commits(@author_commits).sort
    n_commits_length = n_commits.length

    average = average_overall(n_commits)
    deviation = deviation(n_commits, average, n_commits_length)
    min = n_commits[0]
    max = n_commits[n_commits_length - 1]

    median = 0
    first_quartis = 0
    third_quartis = 0
    if (n_commits_length % 2) == 0
      median = median_even(n_commits, n_commits_length)
      first_quartis = q1_even(n_commits, n_commits_length)
      third_quartis = q2_even(n_commits, n_commits_length)
    else
      median = median_odd(n_commits, n_commits_length)
      first_quartis = q1_odd(n_commits, n_commits_length)
      third_quartis = q2_odd(n_commits, n_commits_length)
    end

    puts "cve author commits statistics"
    puts "average: #{average}"
    puts "minimum: #{min}"
    puts "maximum: #{max}"
    puts "median: #{median}"
    puts "first quartis: #{first_quartis}"
    puts "third quartis: #{third_quartis}"
    puts "deviation: #{deviation}"
    puts "END of cve author commits statistics"
    number_commits = {
      "description" => "number of commits",
      "average" => average,
      "minimum" => min,
      "maximum" => max,
      "median" => median,
      "first quartis" => first_quartis,
      "third quartis" => third_quartis,
      "deviation" => deviation
    }
    return number_commits
  end

  # Shows the number of days between the first commit and the CVE on the project
  # Needs to be called after inform_commits_by_author function to load author commits infos
  def inform_authors_experience_days_in_project
    if @author_commits.length == 0
      puts "No authors commits where found, did you call inform_commits_by_author function?"
      return
    end

    n_days = []
    for data in @author_commits
      commits_dates = commits_dates(data['commits']).sort
      date_ini = commits_dates[commits_dates.length - 1]
      date_end = commits_dates[0]
      date_diff = (date_ini && date_end) ? date_ini - date_end : false
      if date_diff
        n_days.append(date_diff.to_i)
        puts "Author with e-mail #{data['author'].email} has been commiting in this projects for the last #{date_diff.to_i} days between #{date_ini} and #{date_end}"
      end
    end

    n_days = n_days.sort
    n_days_length = n_days.length
    average = average_overall(n_days)
    deviation = deviation(n_days, average, n_days_length)
    min = n_days[0]
    max = n_days[n_days_length - 1]

    median = 0
    first_quartis = 0
    third_quartis = 0
    if (n_days_length % 2) == 0
      median = median_even(n_days, n_days_length)
      first_quartis = q1_even(n_days, n_days_length)
      third_quartis = q2_even(n_days, n_days_length)
    else
      median = median_odd(n_days, n_days_length)
      first_quartis = q1_odd(n_days, n_days_length)
      third_quartis = q2_odd(n_days, n_days_length)
    end

    puts "cve author experience statistics in days"
    puts "average: #{average} days"
    puts "minimum: #{min} days"
    puts "maximum: #{max} days"
    puts "median: #{median} days"
    puts "first quartis: #{first_quartis} days"
    puts "third quartis: #{third_quartis} days"
    puts "deviation: #{deviation} days"
    puts "END of cve author experience statistics in days"
    number_commits = {
      "description" => "author experience in days",
      "average" => average,
      "minimum" => min,
      "maximum" => max,
      "median" => median,
      "first quartis" => first_quartis,
      "third quartis" => third_quartis,
      "deviation" => deviation
    }
    return number_commits
  end

  def inform_additions_per_commit
    n_additions = n_additions(@commits).sort
    n_additions_length = n_additions.length

    average = average_overall(n_additions)
    deviation = deviation(n_additions, average, n_additions_length)
    min = n_additions[0]
    max = n_additions[n_additions_length - 1]

    median = 0
    first_quartis = 0
    third_quartis = 0
    if (n_additions_length % 2) == 0
      median = median_even(n_additions, n_additions_length)
      first_quartis = q1_even(n_additions, n_additions_length)
      third_quartis = q2_even(n_additions, n_additions_length)
    else
      median = median_odd(n_additions, n_additions_length)
      first_quartis = q1_odd(n_additions, n_additions_length)
      third_quartis = q2_odd(n_additions, n_additions_length)
    end

    puts "cve commits additions in files statistics"
    puts "average: #{average}"
    puts "minimum: #{min}"
    puts "maximum: #{max}"
    puts "median: #{median}"
    puts "first quartis: #{first_quartis}"
    puts "third quartis: #{third_quartis}"
    puts "deviation: #{deviation}"
    puts "END of cve commits additions in files statistics"
    number_commits = {
      "description" => "number of additions per month",
      "average" => average,
      "minimum" => min,
      "maximum" => max,
      "median" => median,
      "first quartis" => first_quartis,
      "third quartis" => third_quartis,
      "deviation" => deviation
    }
    return number_commits
  end

  def inform_deletions_per_commit
    n_deletions = n_deletions(@commits).sort
    n_deletions_length = n_deletions.length

    average = average_overall(n_deletions)
    deviation = deviation(n_deletions, average, n_deletions_length)
    min = n_deletions[0]
    max = n_deletions[n_deletions_length - 1]

    median = 0
    first_quartis = 0
    third_quartis = 0
    if (n_deletions_length % 2) == 0
      median = median_even(n_deletions, n_deletions_length)
      first_quartis = q1_even(n_deletions, n_deletions_length)
      third_quartis = q2_even(n_deletions, n_deletions_length)
    else
      median = median_odd(n_deletions, n_deletions_length)
      first_quartis = q1_odd(n_deletions, n_deletions_length)
      third_quartis = q2_odd(n_deletions, n_deletions_length)
    end

    puts "cve commits deletions files statistics"
    puts "average: #{average}"
    puts "minimum: #{min}"
    puts "maximum: #{max}"
    puts "median: #{median}"
    puts "first quartis: #{first_quartis}"
    puts "third quartis: #{third_quartis}"
    puts "deviation: #{deviation}"
    puts "END of cve commits deletions files statistics"
    number_commits = {
      "description" => "number of deletions",
      "average" => average,
      "minimum" => min,
      "maximum" => max,
      "median" => median,
      "first quartis" => first_quartis,
      "third quartis" => third_quartis,
      "deviation" => deviation
    }
    return number_commits
  end

  def inform_files_per_commit
    n_files = n_files(@commits).sort
    puts "number of changed files #{n_files(@commits)}"
    n_files_length = n_files.length

    average = average_overall(n_files)
    deviation = deviation(n_files, average, n_files_length)
    min = n_files[0]
    max = n_files[n_files_length - 1]

    median = 0
    first_quartis = 0
    third_quartis = 0
    if (n_files_length % 2) == 0
      median = median_even(n_files, n_files_length)
      first_quartis = q1_even(n_files, n_files_length)
      third_quartis = q2_even(n_files, n_files_length)
    else
      median = median_odd(n_files, n_files_length)
      first_quartis = q1_odd(n_files, n_files_length)
      third_quartis = q2_odd(n_files, n_files_length)
    end

    puts "cve commits changed in files statistics"
    puts "average: #{average}"
    puts "minimum: #{min}"
    puts "maximum: #{max}"
    puts "median: #{median}"
    puts "first quartis: #{first_quartis}"
    puts "third quartis: #{third_quartis}"
    puts "deviation: #{deviation}"
    puts "END of cve commits changed in files statistics"
    number_commits = {
      "description" => "number of changes",
      "average" => average,
      "minimum" => min,
      "maximum" => max,
      "median" => median,
      "first quartis" => first_quartis,
      "third quartis" => third_quartis,
      "deviation" => deviation
    }
    return number_commits
  end

  private

  def average_overall(n_commits_month)
    sum = 0
    for index in n_commits_month
      sum += index
    end

    return sum / n_commits_month.length
  end

  # Takes a list of commits
  # Returns a hash of years, each year is a hash of months
  # Each month has the number of commits in that month
  def n_commits_month(author_commits)
    n_commits_month = {}
    for commit in author_commits
      year, month = commit.commit_date.split('-')
      if n_commits_month.key?(year)
        if n_commits_month[year].key?(month)
          n_commits_month[year][month] += 1
        else
          n_commits_month[year][month] = 1
        end
      else
        n_commits_month[year] = {}
        n_commits_month[year][month] = 1
      end
    end

    return n_commits_month
  end

  # Takes a list of commits
  # Returns the number of commits per month
  def n_commits(commits)
    n_commits_month = []
    for row in commits
      author_commits = row['commits']
      aux = ''
      n_commits = 0
      for commit in author_commits
        year, month = commit.commit_date.split('-')
        if aux == "#{year}-#{month}"
          n_commits += 1
        elsif aux == ''
          n_commits = 1
          aux = "#{year}-#{month}"
        else
          n_commits_month.append(n_commits)
          n_commits = 1
          aux = "#{year}-#{month}"
        end
      end
    end

    return n_commits_month
  end

  def commits_dates(commits)
    commits_dates = []
    for commit in commits
      commits_dates << Date.parse(commit.commit_date)
    end
    commits_dates
  end

  def n_additions(commits)
    n_additions = []
    for row in commits
      n_additions.append(row.num_additions)
    end
    n_additions
  end

  def n_deletions(commits)
    n_deletions = []
    for row in commits
      n_deletions.append(row.num_deletions)
    end
    n_deletions
  end

  def n_files(commits)
    n_files = []
    for row in commits
      n_files.append(row.changed_files.length)
    end
    n_files
  end

  def create_commit_instance(commit_hash)
    json = repo_commit_by_hash(commit_hash)
    puts commit_hash["url"]
    if json.key?('commit')
      message = json['commit']['message']
      num_comments = json['commit']['comment_count']
      commit_date = json['commit']['author']['date']
      num_additions = json['stats']['additions']
      num_deletions = json['stats']['deletions']
      author = create_author_instance(json)
      changed_files = create_commit_files(json)
      url = commit_hash['url']
      Commit.new(commit_hash['hash'], message, num_comments, commit_date, num_additions, num_deletions, author, changed_files, url)
    elsif json.key?('message')
      puts "#{commit_hash['url']}/#{commit_hash['hash']} ERROR: #{json['message'].downcase}"
    end
  end

  def get_commit_dates(commits = nil)
    commit_dates = []
    for commit in (commits ? commits : @commits)
      if commit && commit.commit_date
        commit_dates << commit.commit_date
      end
    end
    commit_dates
  end

  def get_commit_sizes
    commit_sizes = []
    for commit in @commits
      if commit
        commit_sizes << commit.total_number_changes
      end
      
    end
    commit_sizes
  end

  def get_statistics_per_year(commits_dict)
    median = {}
    first_quartis = {}
    third_quartis = {}
    min = {}
    max = {}
    average = {}
    deviation = {}

    for year_key, year in commits_dict
      commits = (year.sort_by {|_key, value| value}.to_h).values
      commits_len = commits.length

      average[year_key] = average(year)
      deviation[year_key] = deviation(commits, average[year_key], commits_len)
      min[year_key] = commits[0]
      max[year_key] = commits[commits_len - 1]

      if (commits_len % 2) == 0
        median[year_key] = median_even(commits, commits_len)
        first_quartis[year_key] = q1_even(commits, commits_len)
        third_quartis[year_key] = q2_even(commits, commits_len)
      else
        median[year_key] = median_odd(commits, commits_len)
        first_quartis[year_key] = q1_odd(commits, commits_len)
        third_quartis[year_key] = q2_odd(commits, commits_len)
      end
    end
    return min, max, median, first_quartis, third_quartis, average, deviation
  end

  def median_even(list, n)
    index = (n / 2) - 1
    median = (list[index] + list[index + 1]) / 2
  end

  def median_odd(list, n)
    median = list[n / 2]
  end

  def q1_even(list, n)
    index = ((n + 2) / 4) - 1
    q1 = list[index]
  end

  def q1_odd(list, n)
    index = ((n + 1) / 4) - 1
    if n < 4
      q1 = list[index]
    else
      q1 = (list[index] + list[index + 1]) / 2
    end
  end

  def q2_even(list, n)
    index = (((3 * n) + 2) / 4) - 1
    q2 = list[index]
  end

  def q2_odd(list, n)
    index = (((3 * n) + 3) / 4) - 1
    if n < 4
      q2 = list[index]
    else
      q2 = (list[index] + list[index + 1]) / 2
    end
  end

  def average(dict)
    sum = 0
    for month_key, month in dict
      sum += month
    end

    average = sum / dict.length
  end

  def deviation(list, average, n)
    sum = 0
    for value in list
      sum += ((value - average) ** 2)
    end

    deviation = Math.sqrt(sum / n)
  end
end