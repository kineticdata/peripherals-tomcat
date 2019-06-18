# Require the dependencies file to load the vendor libraries
require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

require 'rexml/document'
require 'json'

class TomcatWebApplicationReloadV1
  def initialize(input)
    @input_document = REXML::Document.new(input)

    @parameters = {}
    REXML::XPath.match(@input_document, "/handler/parameters/parameter").each do |item|
      @parameters[item.attributes["name"]] = item.text.to_s.strip
    end
  end

  def execute
    begin
      url = "#{@parameters['web_server_address']}/manager/text/reload?path=#{@parameters['web_application_context']}"
      resource = RestClient::Resource.new(url,
                      :user => @parameters['manager_username'],
                      :password => @parameters['manager_password'])
      resource.get
    # If the credentials are invalid
    rescue RestClient::Unauthorized
      raise StandardError, "(Unauthorized): You are not authorized."
    rescue RestClient::BadRequest => error
      raise StandardError, error.response
    end

    # return the results
    "<results/>"
  end

end
