# frozen_string_literal: true

class ClientTicket < DocumentHandler
  attr_reader :online_payment_ticket

  FILE_PATH = "online_payment_tickets/client_ticket.html.erb"

  def initialize(*args)
    @online_payment_ticket = args.at(0)

    opts = if args.last.class == Hash
      args.last
    else
      {}
    end
    opts[:layout] = "pdf"


    super(FILE_PATH, opts)
  end

  private

    def locals
      {
          provider: online_payment_ticket.service.provider,
          client_name: online_payment_ticket.client.label,
          concept: online_payment_ticket.concept,
          amount: online_payment_ticket.amount,
          date: online_payment_ticket.created_at,
          transaction_token: online_payment_ticket.token
      }
    end
end
