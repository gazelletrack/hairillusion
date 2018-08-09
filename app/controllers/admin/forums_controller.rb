class Admin::ForumsController < Admin::ApplicationController 

  before_action :set_admin_forum, only: [:show, :edit, :update, :destroy]

  # GET /admin/forums
  def index
    @forums = Forum.all
  end

  # GET /admin/forums/1
  def show 
  end

  # GET /admin/forums/new
  def new
    @forum = Forum.new
  end

  # GET /admin/forums/1/edit
  def edit
  end

  # POST /admin/forums
  def create
    @forum = Forum.new(admin_forum_params)

    if @forum.save
      redirect_to '/admin/forums', notice: 'Forum was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/forums/1
  def update
    if @forum.update(admin_forum_params)
      redirect_to '/admin/forums', notice: 'Forum was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/forums/1
  def destroy
    @forum.destroy
    redirect_to '/admin/forums', notice: 'Forum was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_forum
      @forum = Forum.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_forum_params
      params.require(:forum).permit(:subject, :content, :approved, :country, :state, :address, :name)
    end
end
