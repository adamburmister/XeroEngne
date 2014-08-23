class XeroOverdueInvoicesService

  def initialize(xero_client)
    @xero_client = xero_client
  end

  def grouped_by_contact
    invoice_models = @xero_client.Invoice.all(where: 'Type=="ACCREC" && AmountDue<>0 && DueDate<=DateTime.Parse("' + Date.today.to_datetime.to_s + '")')

    invoice_attrs_by_contact = {}
    invoice_models.each do |inv|
      invoice = Invoice.new inv.attributes

      invoice_attrs_by_contact[ invoice.contact.id ] = [] unless invoice_attrs_by_contact[ invoice.contact.id ]
      invoice_attrs_by_contact[ invoice.contact.id ] << invoice
    end

    return invoice_attrs_by_contact, invoice_attrs_by_contact.length, invoice_models.length
  end

  def by_invoice_number(invoice_number)
    Invoice.new @xero_client.Invoice.find(invoice_number).attributes
  end

end