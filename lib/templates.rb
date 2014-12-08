require 'erb'

class ApplicationTemplate
  include ERB::Util

  def initialize
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

  def initialize(collection, title, menu)
    @title = title
    @menu = menu
    @href = collection.href

    links = (collection.links || []).partition do |l|
      l.rel != "previous" && l.rel != "next"
    end

    @links = links[0]
    @pagination = links[1]

    @items = collection.items
    @error = collection.error
    unless collection.template.nil?
      @inputs = collection.template.data
    end
    @layout = File.read(File.expand_path('templates/application.html.erb'))
    @content = File.read(File.expand_path('templates/collection.html.erb'))
  end

end

class PagesTemplate < ApplicationTemplate

  def initialize(page, title, menu)
    @title = title
    @menu = menu
    @layout = File.read(File.expand_path('templates/application.html.erb'))
    @content = File.read(File.expand_path("templates/#{page}.html.erb"))
  end

end
