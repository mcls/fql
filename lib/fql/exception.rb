class Fql::Exception < Exception

  attr_reader :type

  def initialize(decoded_json)
    error = decoded_json["error"]
    @type = error["type"]
    super(error["message"])
  end

end
