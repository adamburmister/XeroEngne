module XeroEngine
  class UserPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      @user
    end

    def update?
      @user
    end

    def destroy?
      @user
    end

  end
end