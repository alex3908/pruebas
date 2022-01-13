# frozen_string_literal: true

class API::V1::DiscountsController < API::V1::BaseController
  before_action :load_resource

  # GET
  def index
    json_response(@discounts, :ok)
  end

  # GET
  def show
    json_response(@discount, :ok)
  end

  # POST
  def create
    @discount.stage_id = params[:stage_id]
    if @discount.save
      json_response(@discount, :created)
    else
      json_error_response(@discount.errors, :unprocessable_entity)
    end
  end

  # PATCH/PUT
  def update
    if @discount.update(update_params)
      json_response(@discount, :ok)
    else
      json_error_response(@discount.errors, :unprocessable_entity)
    end
  end

  # DELETE
  def destroy
    @discount.destroy!
    render json: {}, status: :no_content
  end


      private

        # Function for load the requested resources
        def load_resource
          case params[:action].to_sym
          when :index
            @discounts = Discount.filter(filter_params)
          when :create
            @discount = Discount.new(create_params)
          when :show, :update, :destroy
            @discount = Discount.find(params[:id])
          end
        end

        # Return the enterprise params from Request body
        def create_params
          params.require(:discount).permit(:rid, :name, :down_payment, :discount, :total_payments, :stage_id, :dfp, :is_active)
        end

        # Function for get Request params
        def update_params
          create_params
        end

        # Function for get filter params
        def filter_params
          params.slice(*Discount.search_scopes)
        end
end
