class CommitAuthor

  attr_reader :login, :email, :owned_repositories_urls, :followers_logins

  def initialize(login, email)
    @login = login
    @email = email
    @owned_repositories_urls = fill_repositores
    @followers_logins = fill_followers
  end

  def fill_repositores
    # TODO
    []
  end

  def fill_followers
    #TODO
    []
  end
end