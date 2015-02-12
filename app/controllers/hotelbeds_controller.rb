class HotelbedsController < ActionController::Base

  def book_hotel
    @client = HotelBeds::Client.new(endpoint: :test, username: "ROOMERTRAVUS120584", password: "ROOMERTRAVUS120584")
    @check_in_date = Date.today
    @check_out_date = Date.today + 1
    @hotel_id = params[:hotel_id].to_i
    @destination_code = params[:destination_code]
    @adult_count = params[:adult_count] rescue 2
    @child_count = params[:child_count] rescue 0
    @first_name = params[:first_name] || 'Shany'
    @last_name = params[:last_name] || 'Sh'

    puts "Hotel id #{@hotel_id} between dates #{@check_in_date} to #{@check_out_date}, #{@adult_count} adults and #{@child_count} children. Guest name: #{@first_name} #{@last_name}"
    #search for hotels
    @search_operation = @client.perform_hotel_search({
                                                         check_in_date: @check_in_date,
                                                         check_out_date: @check_out_date,
                                                         rooms: [{ adult_count: @adult_count, child_count: @child_count}],
                                                         destination_code: @destination_code,
                                                         hotel_codes: [@hotel_id]
                                                     })

    @search_response = @search_operation.response



    if @search_operation.errors.any?
      raise StandardError, @search_operation.errors.full_messages.join("\n")
    end
    @search_response = @search_operation.response

    puts "Number of hotels: #{@search_response.hotels.count}"
    # search hotel by other properties
    hotel = @search_response.hotels.first
    # search available room by room type
    rooms = hotel.available_rooms.first

    #add hotel to basket
    @basket_operation = @client.add_hotel_room_to_basket({service: {
                                                   check_in_date: @check_in_date,
                                                   check_out_date: @check_out_date,
                                                   availability_token: hotel.availability_token,
                                                   hotel_code: hotel.code,
                                                   destination_code: hotel.destination.code,
                                                   contract_name: hotel.contract.name,
                                                   contract_incoming_office_code: hotel.contract.incoming_office_code,
                                                   rooms: rooms
                                               }
                                           })

    if @basket_operation.errors.any?
      raise StandardError, @basket_operation.errors.full_messages.join("\n")
    end

    @basket_response = @basket_operation.response

    #confirm purcase
    @agency_reference = SecureRandom.hex[0..15].upcase
    @checkout_operation = @client.confirm_purchase({purchase:
                                                        {
                                                           agency_reference: @agency_reference,
                                                           token: @basket_response.purchase.token,
                                                           holder: {
                                                               id: "1",
                                                               type: :adult,
                                                               name: @first_name,
                                                               last_name: @last_name,
                                                               age: "43"
                                                           },
                                                           services: @basket_response.purchase.services.map { |service|
                                                           {
                                                               id: service.id,
                                                               type: service.type,
                                                               customers: [
                                                                   { id: "1", type: :adult, name: "David", last_name: "Smith", age: "43" },
                                                                   { id: "2", type: :adult, name: "Jane", last_name: "Smith", age: "40" }
                                                               ]
                                                           }
                                                         }
                                                       }
                                                   })

    if @checkout_operation.errors.any?
      raise StandardError, @checkout_operation.errors.full_messages.join("\n")
    end

    @checkout_response = @checkout_operation.response

    render :json => {:hotel => hotel,
                     :basket_response => @basket_response,
                     :checkout_response => @checkout_response}

    # #flush purchase
    # @flush_operation = @client.flush_purchase({
    #                                               purchase_token: @basket_response.purchase.token
    #                                           })
    # if @flush_operation.errors.any?
    #   puts @flush_operation.errors.full_messages.join("\n")
    #   # raise StandardError, @flush_operation.errors.full_messages.join("\n")
    # end
    # @flush_response = @flush_operation.response
    #
    # render :json => {:total_results => @search_response.hotels.count,
    #                  :hotel => hotel,
    #                  :basket_response => @basket_response,
    #                  :flush_response => @flush_response,
    #                  :response => @search_response.hotels}
  end


  def search_hotels
    @client = HotelBeds::Client.new(endpoint: :test, username: "ROOMERTRAVUS120584", password: "ROOMERTRAVUS120584")
    @check_in_date = Date.today
    @check_out_date = Date.today + 1

    #search for hotels
    @search_operation = @client.perform_hotel_search({
                                             check_in_date: @check_in_date,
                                             check_out_date: @check_out_date,
                                             rooms: [{ adult_count: 2 }],
                                             destination_code: params[:destination_code],
                                             hotel_codes: [369145, 159670]
                                         })

    @search_response = @search_operation.response



    if @search_operation.errors.any?
      raise StandardError, @search_operation.errors.full_messages.join("\n")
    end
    @search_response = @search_operation.response

    render :json => {:total_results => @search_response.hotels.count,
                     :response => @search_response.hotels}
  end


end
