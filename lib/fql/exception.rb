class Fql::Exception < Exception

  attr_reader :type, :decoded_json

  def initialize(decoded_json)
    error = decoded_json["error"]
    @type = error["type"]
    @decoded_json = decoded_json
    super(error["message"])
  end

end
