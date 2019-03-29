class SubscriptionsController < ApplicationController
  def create
    result = ::Subscriptions::Creator.new.call(params.permit!.to_h)

    if result.success?
      head :created
    else
      render json: {errors: result.errors}, status: :bad_request
    end
  rescue ::Fakepay::Client::NetworkConnectionError => e
    render json: {errors: [e.message]}, status: :interal_error
  end
end
