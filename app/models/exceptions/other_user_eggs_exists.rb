 class Exceptions::OtherUsersEggsExists < StandardError
    attr_writer :default_message

    def initialize(message = nil)
      @message= message
      @default_message = "There are eggs of other users in this location."
    end

    def to_s
      @message || @default_message
    end
  end
