require 'erb'

class CollectionTemplate
  include ERB::Util
  attr_accessor :href

  def initialize(collection)
    @href = collection.href
    @items = collection.items
    @error = collection.error
    unless collection.template.nil?
      @inputs = collection.template.data
    end
    @template = %{
      <!DOCTYPE html>
      <html>
      <head>
        <title>Reviews</title>
        <style>
          body {
            font-family: monospace;
          }
          label {
            display: block;
          }
          .error {
            display: block;
            color: #F8F8F8;
            background-color: #AB4642;
            padding: 1em;
          }
        </style>
      </head>
      <body>
      <h1><a href="<%= @href %>">Reviews</a></h1>
      <div>
      <% unless @error.nil? %>
        <div class="error">
          Error: <%= @error.title %><br/>
          <%= @error.message %>
        </div>
      <% end %>
      <% for @item in @items %>
        <hr/>
        <dl>
          <dt>
          <a href="<%= @item.href %>">
            <%= @item.href %>
          </a>
          </dt>
            <% for link in @item.links %>
              <dd><%= link.prompt %>: <%= link.href %></dd>
            <% end %>
            <% for datum in @item.data %>
              <% unless datum.value.nil? %>
                <dd><%= datum.prompt %>: <%= datum.value %></dd>
              <% end %>
            <% end %>
        </dl>
        </body>
      <% end %>
      <hr/>
      <% unless @inputs.nil? %>
      <form method="POST">
      <% for @input in @inputs %>
        <label for="<%= @input.name %>">
          <%= @input.prompt %>
        </label>
        <input type="text" name="<%= @input.name %>" autocomplete="off"/>
      <% end %>
      <input type="submit" value="Submit"/>
      </form>
      <% end %>
      </div>
    }
  end

  def render()
    ERB.new(@template).result(binding)
  end

end
