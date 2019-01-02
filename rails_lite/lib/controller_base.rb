require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params, :already_built_response

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise 'Double Render Error'
    else
      @res.set_header('Location', url)
      @res.status = 302
      session.store_session(@res)
      @res.finish
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise 'Double Render Error'
    else
      @res.set_header('Content-Type', content_type)
      @res.write(content)
      session.store_session(@res)
      @res.finish
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    parent_path = File.dirname(__FILE__)
    controller_name = self.class.name.underscore
    template = template_name.to_s + '.html.erb'
    full_path = File.join(parent_path, '..', 'views', controller_name, template)
    contents = ERB.new(File.read(full_path)).result(binding)
    render_content(contents, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

