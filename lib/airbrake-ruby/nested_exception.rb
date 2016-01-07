module Airbrake
  ##
  # A class that is capable of unwinding nested exceptions and representing them
  # as JSON-like hash.
  class NestedException
    ##
    # @return [Integer] the maximum number of nested exceptions that a notice
    #   can unwrap. Exceptions that have a longer cause chain will be ignored
    MAX_NESTED_EXCEPTIONS = 3

    def initialize(exception)
      @exception = exception
    end

    def as_json
      unwind_exceptions.map do |exception|
        { type: exception.class.name,
          message: exception.message,
          backtrace: parse_backtrace(exception) }
      end
    end

    private

    def unwind_exceptions
      exception_list = []
      exception = @exception

      while exception && exception_list.size < MAX_NESTED_EXCEPTIONS
        exception_list << exception
        exception = (exception.cause if exception.respond_to?(:cause))
      end

      exception_list
    end

    def parse_backtrace(exception)
      return if exception.backtrace.nil? || exception.backtrace.none?
      Backtrace.parse(exception)
    end
  end
end
