module XeroEngine
  class AfterSignupController < AuthorisedController
    include Wicked::Wizard

    STEPS = [:welcome, :address, :print_settings, :done]

    skip_filter :ensure_setup_wizard_completed, :warn_no_stripe_card_payment_method
    before_filter :ensure_current_organisation

    steps :welcome, :address, :print_settings, :done

    def show
      case wizard_value(step)
      when :welcome
        ensure_current_organisation
        if current_organisation && current_organisation.furthest_setup_step > 0
          jump_to(steps[current_organisation.furthest_setup_step])
        end
      when :address
        @addresses = addresses_for_current_organisation
        if @addresses.length == 1
          if current_organisation.address.blank?
            current_organisation.build_address.from_xero_obj(@addresses.first)
          end
        end
      when :print_settings
        redirect_to previous_wizard_path and return if !current_organisation
        @print_settings = current_organisation.print_settings
      end
      render_wizard
    end

    def update
      case wizard_value(step)
      when :address
        # if address_params[:has_verified_suggestion]
        jump_to next_step if current_organisation.address.update(address_params)
        # else
        #   @prev_address = Address.new.from_lob_obj(address_params)

        #   current_organisation.address.update(address_params)

        #   # Attempt to verify the address, catching exceptions
        #   begin
        #     current_organisation.address.verify
        #   rescue

        #   end

        #   @has_suggested_address = current_organisation.address.changed?

        #   jump_to :billing unless @has_suggested_address
        # end
      when :print_settings
        jump_to next_step if current_organisation.print_settings.update(print_settings_params)
      end

      current_organisation.update(furthest_setup_step: steps.index(step) + 1)
      render_wizard
    end

    def finish_wizard_path
      dashboard_path
    end

  private

    def addresses_for_current_organisation
      @addresses = xero_client.Organisation.first.addresses.reject {|a| a.type != 'POBOX'}
    end

    def address_params
      params.require(:address).permit(:address_line1, :address_line2, :city, :state, :zip, :country, :has_verified_suggestion)
    end

    def print_settings_params
      params.require(:print_settings).permit(:color, :delivery, :trigger)
    end

  end
end
