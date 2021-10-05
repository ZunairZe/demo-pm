class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :add_index_breadcrumb, only: [:show, :edit, :new]

  # GET projects/1/tasks
  def index
    @tasks = @project.tasks
    add_breadcrumbs('All Tasks')
  end

  # GET projects/1/tasks/1
  def show
    add_breadcrumbs(@task.name)
  end

  # GET projects/1/tasks/new
  def new
    @task = @project.tasks.build
    add_breadcrumbs('New Task')
  end

  # GET projects/1/tasks/1/edit
  def edit
    add_breadcrumbs('Edit')
  end

  # POST projects/1/tasks
  def create
    @task = @project.tasks.build(task_params)
    respond_to do |format|
      if @task.save
        UserMailer.with(user: @user, task: @task).send_task_alert.deliver_later
        format.html { redirect_to @task.project, notice: "Task was successfully created." }
      else
        render action: 'new'
      end
    end
  end

  def assign
    @project = Project.find(params[:project_id])
    @task = Task.find(params[:id])
  end

  # PUT projects/1/tasks/1
  def update
    if @task.update(task_params)
      if params[:task][:user_id].present?
        @user = User.find(@task.user_id)
        UserMailer.with(user: @user, task: @task).send_task_alert.deliver_later
      end
      respond_to do |format|
        if current_user.admin == true
          format.html { redirect_to @task.project, notice: "Task was successfully updated." }
        else
          redirect_to(employees_index_path)
        end
      end
    else
      render action: 'edit'
    end
  end

  # DELETE projects/1/tasks/1
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to @project, alert: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_task
      @task = @project.tasks.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def task_params
      params.require(:task).permit(:name, :description, :status, :project_id, :hours_worked, :hours, :user_id, :starting_date, :ending_date)
    end

    def add_index_breadcrumb
      add_breadcrumbs('Project', project_path(@project))
    end
end
