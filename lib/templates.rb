require 'erb'

class ApplicationTemplate
  include ERB::Util

  def initialize(collection, title = nil)
    @layout = File.read(File.expand_path('templates/application.html.erb'))
    @content = File.read(File.expand_path('templates/blank.html.erb'))
  end

  def partial content
    t = ERB.new(content)
    t.result(binding)
  end

  def render()
    ERB.new(@layout).result(binding)
  end

end

class CollectionTemplate < ApplicationTemplate
  attr_accessor :href

  def initialize(collection, title = nil)
    @title = title
    @href = collection.href
    @items = collection.items
    @error = collection.error
    unless collection.template.nil?
      @inputs = collection.template.data
    end
    @layout = File.read(File.expand_path('templates/application.html.erb'))
    @content = File.read(File.expand_path('templates/collection.html.erb'))
  end

end
