class PaymentsController < ApplicationController
  def index
    render json: Payment.all
  end
  def create
    #payment=Payment.new(amount:params(:amount),description:params(:'description'))
    payment=Payment.new(payment_params)
    if payment.save
      render json:payment, status: :created

    else
      render json:payment.errors, status: :unprocessable_entity
    end
  end

  private
  def payment_params
    params.require(:payment).permit(:amount,:description)
     
  end
end
 