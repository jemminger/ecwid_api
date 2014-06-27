require 'faraday'
require 'faraday_middleware'

module EcwidApi
  # Public: Client objects manage the connection and interface to a single Ecwid
  # store.
  #
  # Examples
  #
  #   client = EcwidApi::Client.new do |config|
  #     config.store_id = '12345'
  #     config.url = 'http://app.ecwid.com/api/v1'
  #     config.order_secret_key = 'ORDER_SECRET_KEY'
  #     config.product_secret_key = 'PRODUCT_SECRET_KEY'
  #   end
  #
  class Client
    # The default base URL for the Ecwid API
    DEFAULT_URL = "https://app.ecwid.com/api/v1"

    # Public: Returns the Ecwid Store ID
    attr_reader :store_id

    # Public: Gets or sets the Order API Secret Key for the Ecwid Store
    attr_accessor :order_secret_key

    # Public: Gets or sets the default Product API Secret Key for the Ecwid Store
    attr_accessor :product_secret_key

    def initialize
      yield(self) if block_given?
      raise Error.new("The store_id is required") unless store_id
    end

    # Public: Returns the base URL of the Ecwid API
    def url
      @url || DEFAULT_URL
    end

    # Public: Sets the base URL for the Ecwid API
    def url=(url)
      reset_connection
      @url = url
    end

    # Public: Sets the Ecwid Store ID
    def store_id=(store_id)
      reset_connection
      @store_id = store_id
    end

    # Public: The URL of the API for the Ecwid Store
    def store_url
      "#{url}/#{store_id}"
    end

    # Public: Sends a GET request to the Ecwid API
    #
    # path   - The String path for the URL of the request without the base URL
    # params - A Hash of query string parameters
    #
    # Examples
    #
    #   # Gets the Categories where the parent Category is 1
    #   client.get("categories", parent: 1)
    #   # => #<Faraday::Response>
    #
    # Returns a Faraday::Response
    def get(path, params={})
      connection.get(path, params)
    end

    # Public: Sends a POST request to the Ecwid API
    #
    # path - The String path for the URL of the request without the base URL
    # params - A Hash of query string parameters
    #
    # Returns a Faraday::Response
    def post(path, params={})
      connection.post(path, params)
    end

    # Public: Returns the Category API
    def categories
      @categories ||= CategoryApi.new(self)
    end

    # Public: Returns the Order API
    def orders
      @orders ||= OrderApi.new(self)
    end

    private

    # Private: Resets the connection.
    #
    # Should be used if the base URL to the Ecwid API changes
    def reset_connection
      @connection = nil
    end

    # Private: Returns a Faraday connection to interface with the Ecwid API
    def connection
      @connection ||= Faraday.new store_url do |conn|
        conn.request  :url_encoded
        conn.response :json, content_type: /\bjson$/
        conn.adapter  Faraday.default_adapter
      end
    end
  end
end