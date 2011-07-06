module Cod
  # Wraps the lower level beanstalk connection and exposes only methods that
  # we need; also makes tube handling a bit more predictable. 
  #
  # This class is NOT thread safe.
  #
  class Connection::Beanstalk
    # The url that was used to connect to the beanstalk server. 
    attr_reader :url
    
    # Connection to the beanstalk server. 
    attr_reader :connection
    
    def initialize(url)
      @url = url
      # TODO throws Errno::ECONNREFUSED if the beanstalkd doesn't answer
      @connection = Beanstalk::Connection.new(url)
      @watching = nil
    end
    
    # Writes a raw message as a job to the tube given by name. 
    #
    def put(name, message)
      connection.use name
      # TODO throws EOFError when the beanstalkd server goes away
      connection.put message
    end
    
    # Returns true if there are jobs waiting in the tube given by 'name'
    def waiting?(name)
      watch(name) do  
        # TODO throws EOFError when beanstalkd goes away.
        !! connection.peek_ready
      end
    end
    
    # Removes and returns the next message waiting in the tube given by name.
    #
    def get(name, opts={})
      watch(name) do
        job = connection.reserve(opts[:timeout])
        job.delete
        
        job.body
      end
    end
    
    # Closes the connection
    #
    def close
      @connection = nil
    end
  private
    def watch(name)
      unless @watching == name
        connection.ignore(@watching)
        connection.watch(name)
        @watching = name
      end
      
      yield
    end
  end
end