class Wechat::Admin::TicketsController < Wechat::Admin::BaseController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  def index
    q_params = {}
    q_params.merge! default_params
    @tickets = Ticket.default_where(q_params).page(params[:page])
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)

    unless @ticket.save
      render :new, locals: { model: @ticket }, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @ticket.assign_attributes(ticket_params)

    unless @ticket.save
      render :edit, locals: { model: @ticket }, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket.destroy
  end

  private
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    p = params.fetch(:ticket, {}).permit(
      :match_value,
      :serial_start,
      :start_at,
      :finish_at,
      :valid_response,
      :invalid_response
    )
    p.merge! default_form_params
  end

end
