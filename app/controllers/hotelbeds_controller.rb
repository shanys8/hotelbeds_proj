class HotelbedsController < ActionController::Base

  def search_hotels
    client = HotelBeds::Client.new(endpoint: :test, username: "ROOMERTRAVUS120584", password: "ROOMERTRAVUS120584")
    search = client.perform_hotel_search({
                                             check_in_date: Date.today,
                                             check_out_date: Date.today + 1,
                                             rooms: [{ adult_count: 2 }],
                                             destination_code: "SYD"
                                         })

    render :json => {:total_results => search.response.hotels.count, :response => search.response.hotels}
  end

end
