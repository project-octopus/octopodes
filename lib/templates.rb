require 'erb'

class CollectionTemplate
  include ERB::Util
  attr_accessor :href

  def initialize(collection, title = nil)
    @title = title
    @href = collection.href
    @items = collection.items
    @error = collection.error
    unless collection.template.nil?
      @inputs = collection.template.data
    end
    @template = File.read(File.expand_path('templates/application.html.erb'))
  end

  def render()
    ERB.new(@template).result(binding)
  end

end
