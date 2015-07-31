class Api::V1::ErrorsController < Api::V1::ApiController
	skip_before_action :authenticate_member!, except: [:index, :show, :update, :notify_subscribers]

	def index
		@errors = current_site.issues
	end

	def create
		subscriber = current_site.subscribers.create_with(name: params[:name]).find_or_create_by(email: params[:email])
		error = current_site.issues.find_or_create_by(page_title: params[:page_title], description: 'etc', status: :unresolved)
		error.subscribers.find_or_create_by(subscriber_id: subscriber.id)
		message = Message.create(content: params['message'], issue_id: error.id)
	end

	def show
		@error = current_site.issues.where('issues.id = ?', params[:id]).first
	end

	 def update
		@error = Issue.find(params[:id])
		@error.update_attributes(error_params)
	end

	def notify_subscribers
		@error = Issue.find(params[:id])
		@message = params[:message]
		@error.subscribers.each do |member|
			UserMailer.notify_subscriber(@error, member, @message).deliver_now
		end
	end


	private
		def error_params
			params.require(:error).permit(:status)
		end
end
