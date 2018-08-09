class Admin::DomainDistributorsController < Admin::ApplicationController 
  before_action :set_admin_domain_distributor, only: [:show, :edit, :update, :destroy]

  # GET /admin/domain_distributors
  def index
    @domain_distributors = DomainDistributor.all.order("created_at desc").page(params[:page]).per_page(10)
  end

  # GET /admin/domain_distributors/1
  def show
    @distributor_orders = @domain_distributor.distributor_orders.order("DATE(created_at) DESC").page(params[:page]).per_page(10)
  end
  
  def download_report   
    @domain_distributor = DomainDistributor.find params[:distributor_id]
    @distributor_orders = @domain_distributor.distributor_orders.where("DATE(created_at) >= ? and DATE(created_at) <=?", params[:start_date].to_datetime.utc ,params[:end_date].to_datetime.utc).order("DATE(created_at) DESC") 
    render :pdf => "#{@domain_distributor.name}", :layout => 'pdf.html.erb'   
  end

  # GET /admin/domain_distributors/new
  def new
    @domain_distributor = DomainDistributor.new
  end

  # GET /admin/domain_distributors/1/edit
  def edit
  end
  
  def filter_report
    @domain_distributor = DomainDistributor.find params[:domain_distributor_id] 
    @distributor_orders = @domain_distributor.distributor_orders.where("DATE(created_at) >= ? and DATE(created_at) <=?", params[:search][:start_date].to_datetime.utc ,params[:search][:end_date].to_datetime.utc).order("DATE(created_at) DESC").page(params[:page]).per_page(10)
  end

  # POST /admin/domain_distributors
  def create
    @domain_distributor = DomainDistributor.new(domain_distributor_params)

    if @domain_distributor.save
      redirect_to '/admin/domain_distributors', notice: 'Domain distributor was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/domain_distributors/1
  def update
    if @domain_distributor.update(domain_distributor_params)
       redirect_to '/admin/domain_distributors', notice: 'Domain distributor was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/domain_distributors/1
  def destroy
    @domain_distributor.destroy
    redirect_to admin_domain_distributors_url, notice: 'Domain distributor was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_domain_distributor
      @domain_distributor = DomainDistributor.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def domain_distributor_params
      params.require(:domain_distributor).permit(:domain, :name, :company_name, :email, :percentage, :phone, :address, :state, :country, :zip)
    end
end
