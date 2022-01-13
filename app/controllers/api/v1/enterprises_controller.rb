# frozen_string_literal: true

class API::V1::EnterprisesController < API::V1::BaseController
  before_action :load_resource

  # GET
  def index
    json_response(@enterprises, :ok)
  end

  # GET
  def show
    json_response(@enterprise, :ok)
  end

  # POST
  def create
    if @enterprise.save
      json_response(@enterprise, :created)
    else
      json_response(@enterprise.errors, :unprocessable_entity)
    end
  end

  # PATCH/PUT
  def update
    if @enterprise.update(update_params)
      json_response(@enterprise, :ok)
    else
      json_response(@enterprise.errors, :unprocessable_entity)
    end
  end

  # DELETE
  def destroy
    @enterprise.destroy!
    render json: {}, status: :no_content
  end


    private

      # Function for load the requested resources
      def load_resource
        case params[:action].to_sym
        when :index
          @enterprises = Enterprise.filter(filter_params)
        when :create
          @enterprise = Enterprise.new(create_params)
        when :show, :update, :destroy
          @enterprise = Enterprise.find(params[:id])
        end
      end

      # Return the enterprise params from Request body
      def create_params
        params.require(:enterprise).permit(:business_name, :short_business_name, :rfc, :state, :country,
            :location, :street, :outdoor_number, :indoor_number, :colony, :postal_code)
      end

      # Function for get Request params
      def update_params
        create_params
      end

      # Function for get filter params
      def filter_params
        params.slice(*Enterprise.search_scopes)
      end
end
