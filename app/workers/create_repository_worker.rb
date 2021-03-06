class CreateRepositoryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :repo, unique: :until_executed

  def perform(host_type, repo_name, token = nil)
    Repository.create_from_host(host_type, repo_name, token)
  end
end
