class Api::RepositoryUsersController < Api::ApplicationController
  before_action :find_user

  def show
    render json: @repository_user.as_json({methods: [:github_id, :user_type]})
  end

  def repositories
    @repositories = @repository_user.repositories.open_source.source.order('stargazers_count DESC, rank DESC NULLS LAST')

    paginate json: @repositories.as_json({ except: [:id, :repository_organisation_id, :repository_user_id], methods: [:github_contributions_count, :github_id] })
  end

  def projects
    @projects = @repository_user.projects.joins(:repository).includes(:versions).order('projects.rank DESC NULLS LAST, projects.created_at DESC')
    @projects = @projects.keywords(params[:keywords].split(',')) if params[:keywords].present?

    paginate json: project_json_response(@projects)
  end

  private

  def find_user
    @repository_user = RepositoryUser.host(current_host).visible.where("lower(login) = ?", params[:login].downcase).first
    @repository_user = RepositoryOrganisation.host(current_host).visible.where("lower(login) = ?", params[:login].downcase).first if @repository_user.nil?
    raise ActiveRecord::RecordNotFound if @repository_user.nil?
  end
end
