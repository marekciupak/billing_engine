class SubscriptionsController < ApplicationController
  def create
    result = ::Subscriptions::Creator.new.call(params.permit!.to_h)

    if result.success?
      render json: {subscription: present_subscription(result.data)}, status: :created
    else
      render json: {errors: result.errors}, status: :bad_request
    end
  rescue ::Fakepay::Client::NetworkConnectionError => e
    logger.error e
    render json: {errors: {internal: 'Something went wrong!'}}, status: :interal_error
  end

  private

  def present_subscription(subscription)
    {
      id: subscription.id,
      expires_on: subscription.expires_on,
    }
  end
end
