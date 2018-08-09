class Admin::CustomersController < Admin::ApplicationController
  respond_to :html
  respond_to :js, only: [:index]

  def index
    respond_to do |format|
      format.html {}
      format.js do
        @customers = Customer.all

        grid_table_for(@customers, index_params)
      end
    end
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  private
  def index_params
    params.permit [].concat(Customer.grid_table_strong_params)
  end
end
