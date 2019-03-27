class SubscriptionsController < ApplicationController
  def create
    result = ::Subscription::Creator.new.call(params.permit!.to_h)

    if result.success?
      head :created
    else
      render json: {errors: result.errors}, status: :bad_request
    end
  end
end
