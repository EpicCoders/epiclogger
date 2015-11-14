class Api::V1::StoreController < Api::V1::ApiController
  require 'digest/md5'
  require 'net/http'
  require 'uri'
  skip_before_action :authenticate_member!

  def create
    subscriber = current_site.subscribers.create_with(name: "Name for subscriber").find_or_create_by!(email: error_params["user"]["email"], website_id: current_site.id)
    if error_params["stacktrace"].blank?
      checksum = Digest::MD5.hexdigest(error_params["platform"] + error_params["culprit"] + error_params["message"])
    else
      checksum = Digest::MD5.hexdigest(error_params["stacktrace"].to_s)
    end
    groupedissue = GroupedIssue.find_by_data_and_website_id(checksum,current_site.id) 
    if groupedissue.nil?
      @group = GroupedIssue.create_with(
        issue_logger: error_params["logger"],
        view: error_params["request"].to_s.gsub('=>', ':'),
        status: 3,platform: error_params["platform"],
        message: error_params["message"],
        times_seen: 1,
        first_seen: Time.now,
        last_seen: Time.now
      )
    else
      groupedissue.update_attributes(
        :times_seen => groupedissue.times_seen + 1,
        :last_seen => Time.now
      )
    end

    @group = GroupedIssue.create_with(
      issue_logger: error_params["logger"],
      view: error_params["request"].to_s.gsub('=>', ':'),
      status: 3,platform: error_params["platform"],
      message: error_params["message"]
    ).find_or_create_by(data: checksum, website_id: current_site.id)

    source_code = open_url_content(error_params["stacktrace"])

    @error = Issue.create_with(
      description: error_params["stacktrace"]["frames"].to_s.gsub('=>', ':'),
      page_title: error_params["extra"]["title"],
      platform: error_params["platform"],
      group_id: @group.id  
      # error_params["stacktrace"]["frames"].to_s.gsub(/=>|\./, ":")
    ).find_or_create_by(data: source_code, subscriber_id: subscriber.id)

    message = Message.create(content: error_params["message"], issue_id: @error.id)
  end

  def open_url_content(stacktrace)
    nr = 0
    content = []
    stacktrace["frames"].each do |frame|
      nr +=1
      content.push({"content_#{nr}" => Net::HTTP.get(URI.parse(frame["filename"]))})
      # content += "," if nr > 0
    end
    content.to_s.gsub('=>', ':')
  end

  private
    def error_params
      # check here if we have a post or a get.
      if request.get?
        # this means that tha request is sent by a client call (js client)
        error_params ||= JSON.parse(params[:sentry_data])    
      elsif request.post?
        # this means that the request is sent by a server call
        data = Zlib::Inflate.inflate(Base64.decode64(request.body.read))
        error_params ||= JSON.parse(data)
      end
    end
end
