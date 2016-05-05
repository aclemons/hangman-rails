class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale

  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?

  protected

  def json_request?
    request.format.json?
  end

  def set_pagination_header(scope, options = {})
    request_params = request.query_parameters
    url_without_params = request.original_url.slice(0..(request.original_url.index("?") - 1 )) unless request_params.empty?
    url_without_params ||= request.original_url

    page = {}
    page[:first] = 1 if scope.total_pages > 1 && scope.previous_page
    page[:last] = scope.total_pages  if scope.total_pages > 1 && scope.next_page
    page[:next] = scope.next_page if scope.next_page
    page[:prev] = scope.previous_page if scope.previous_page

    headers["Link"] = page.each_with_object([]) do |(k, v), links|
      new_request_hash = request_params.merge({ :page => v })
      links << "<#{url_without_params}?#{new_request_hash.to_param}>; rel=\"#{k}\""
    end.join(", ")
  end

  def not_found
    respond_to do |format|
      format.html { render :file => File.join(Rails.root, 'public', '404.html') }
      format.json { render json: "{}", status: :bad_request }
    end
  end
end
