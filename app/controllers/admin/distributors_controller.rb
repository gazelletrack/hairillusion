class Admin::DistributorsController < Admin::ApplicationController
  respond_to :html
  respond_to :js, only: [:index]

  def index
    respond_to do |format|
      format.html {}
      format.js do
        @distributors = Distributor.all

        grid_table_for(@distributors, index_params)
      end
    end
  end

  def show
    @distributor = Distributor.find(params[:id])
  end

  def new
    @distributor = Distributor.new
  end

  def create
    @distributor = Distributor.new(distributor_params)

    if @distributor.save
      redirect_to admin_distributor_path(@distributor)
    else
      render :new
    end
  end

  def edit
    @distributor = Distributor.find(params[:id])
  end

  def update
    @distributor = Distributor.find(params[:id])
    @distributor.skip_password_required = true

    if @distributor.update_attributes(distributor_params)
      redirect_to admin_distributor_path(@distributor)
    else
      render :edit
    end
  end

  def approve
    @distributor = Distributor.find(params[:id]) 
    stripe_customer = Stripe::Customer.create(
      email: @distributor.email
    ) 
    password = "hairillusion" 
    if @distributor.update_attributes(password: password, password_confirmation: password, require_password_reset: true, approved: true, stripe_id: stripe_customer.id)
      DistributorMailer.approved(@distributor, password).deliver! 
      redirect_to admin_distributor_path(@distributor)
    else
      render :show
    end
  end

  private
  def index_params
    params.permit [].concat(Distributor.grid_table_strong_params)
  end

  def distributor_params
    distributor_params = params.require(:distributor).permit(:country,:company_name, :first_name, :last_name, :tax_id, :email, :phone, :address1, :address2, :city, :state, :zip, :price)
    distributor_params[:price] = distributor_params[:price].to_f * 100 unless distributor_params[:price].blank?

    distributor_params
  end
end
