class Admin::ShipmentsController < Admin::ApplicationController
  respond_to :html
  respond_to :js, only: [:index]
  respond_to :xml, only: [:show]

  def index
    respond_to do |format|
      format.html {}
      format.js do
        @shipments = Shipment.all
        grid_table_for(@shipments, index_params)
      end
    end
  end

  def show
    @shipment = Shipment.find(params[:id])

    respond_to do |format|
      format.html {}
      format.xml { send_data(render_to_string( template: 'admin/shipments/show' ), filename: 'shipment.xml') }
    end
  end

  def create
    @shipment = Shipment.new
    @shipment.orders<< Order.unshipped.order(:created_at)

    @shipment.save

    redirect_to admin_shipment_path(@shipment)
  end

  private
  def index_params
    params.permit [].concat(Shipment.grid_table_strong_params)
  end
end
