#
# Copyright (C) 2016 Powershop New Zealand Ltd
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale

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
end
