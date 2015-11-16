class ErrorStore

  def initialize(request, data)
    @request = request
    @data    = data
  end

  def get
    # decode get request data
  end

  def post
    # decode post request data
    data = request.body.read
    response_or_event_id = process

    # if isinstance(response_or_event_id, HttpResponse):
    #   return response_or_event_id
    # return HttpResponse(json.dumps({
    #     'id': response_or_event_id,
    # }), content_type='application/json')
  end

  private
  def process
    
  end

end