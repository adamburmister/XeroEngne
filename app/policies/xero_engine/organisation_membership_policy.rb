module XeroEngine
  class OrganisationMembershipPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def show?
      @record.user == @user
    end

    def expired?
      @record.user == @user
    end

    def destroy?
      @record.user == @user
    end

  end
end