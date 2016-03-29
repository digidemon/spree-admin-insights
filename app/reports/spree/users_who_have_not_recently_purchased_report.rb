module Spree
  class UsersWhoHaveNotRecentlyPurchasedReport < Spree::Report
    HEADERS = [:user_email, :last_purchase_date, :last_purchased_order_number]

    def self.assign_search_params(options)
      super
      @email_cont = @search[:email_cont].present? ? "%#{ @search[:email_cont] }%" : '%'
    end

    def self.generate(options = {})
      assign_search_params(options)
      all_orders_with_users = SpreeReportify::ReportDb[:spree_users___users].
      left_join(:spree_orders___orders, user_id: :id).
      where(orders__completed_at: nil, orders__number: nil).
      or(Sequel.~(orders__completed_at: nil), Sequel.~(orders__completed_at: @start_date..@end_date)).
      where(Sequel.ilike(:users__email, @email_cont)).
      order(Sequel.desc(:orders__completed_at)).
      select(
        :users__email___user_email,
        :orders__number___last_purchased_order_number,
        :orders__completed_at___last_purchase_date
      ).as(:all_orders_with_users)

      SpreeReportify::ReportDb[all_orders_with_users].
      select_all.
      group(:all_orders_with_users__user_email)
    end

  end
end