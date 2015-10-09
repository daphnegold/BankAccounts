require 'csv'

module Bank

  class Owner

    attr_accessor :id, :last, :first, :street, :city, :state, :accounts

    def initialize(id, last, first, street = nil, city = nil, state = nil)
      @id = id.to_i
      @first = first
      @last = last
      @street = street
      @city = city
      @state = state
      @accounts = {}
    end

    def self.all
      owners_list = []
      owners_csv = CSV.read("./support/owners.csv")

      owners_csv.each do |row|
        owner = Bank::Owner.new(row[0], row[1], row[2], row[3], row[4], row[5])
        owners_list.push(owner)
      end

      return owners_list
    end

    def self.find(id)
      owners_list = self.all

      owners_list.find do |instance|
        instance.id == id
      end
    end

    def self.master_list # Accounts and their respective owners in one big happy array
      master_list = []
      account_owners_csv = CSV.read("./support/account_owners.csv")

      account_owners_csv.each do |row|
        account = Bank::Account.find(row[0].to_i)
        account_owner = self.find(row[1].to_i)

        account_owner.accounts[:account] = account
        master_list.push(account_owner)
        account.owner = account_owner
      end

      return master_list
    end

    def self.find_owner(id) # Find an account from the master_list! Then you can do stuff with it! Yay!
      master_list = self.master_list

      found = master_list.find do |instance|
        instance.id.to_i == id
      end

      return found
    end

  end

  class Account

    attr_reader :balance, :id, :date
    attr_accessor :owner

    FEE = 0
    MIN_BAL = 0

    def initialize(id, initial_balance, open_date = nil, owner = nil)
      @id = id.to_i
      @balance = initial_balance.to_i

      if open_date != nil
        @date = DateTime.strptime(open_date, "%Y-%m-%d %H:%M:%S %z")
      end
      @owner = owner

      raise ArgumentError if @balance < 0
    end

    def withdraw(withdrawal)
      if withdrawal < 0
        print "You cannot withdraw a negative amount. "

        return @balance
      end

      if @balance - withdrawal - self.class::FEE >= self.class::MIN_BAL
        @balance -= (withdrawal + self.class::FEE) if self.class != MoneyMarketAccount
        @balance -= withdrawal if self.class == MoneyMarketAccount
      else
        print "You cannot withdraw that amount. "
      end

      return @balance
    end

    def deposit(deposit_amt)
      if deposit_amt > 0
        @balance += deposit_amt
      else
        print "You can only deposit a positive amount. "
      end

      return @balance
    end

    def self.all # Create array of account instances from accounts.csv
      account_list = []
      account_csv = CSV.read("./support/accounts.csv")

      account_csv.each do |row|
        account = Bank::Account.new(row[0], row[1], row[2])
        account_list.push(account)
      end

      return account_list
    end

    def self.find(id) # Find a particular account from accounts.csv and return its object
      account_list = self.all

      found = account_list.find do |instance|
        instance.id == id
      end

      return found
    end

  end
end
