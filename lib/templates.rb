require 'erb'

class CollectionTemplate
  include ERB::Util
  attr_accessor :href

  def initialize(collection, title = "Octopus Project")
    @title = title
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
        <title>Octopus Project</title>
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootswatch/3.3.0/paper/bootstrap.min.css">
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
      <div class="container-fluid">
        <div class="row">
          <div class="col-xs-10">
            <h1><a href="<%= @href %>"><%= @title %></a></h1>
          </div>
          <div class="col-xs-2">
            <h1>
            <img height="40px" src="https://raw.githubusercontent.com/project-octopus/octopodes/master/vendor/assets/icon_15331/icon_15331_small.png"/>
            </h1>
          </div>
        </div>
        <div class="row">
          <div class="col-lg-12">
            <% unless @error.nil? %>
              <div class="error">
                Error: <%= @error.title %><br/>
                <%= @error.message %>
              </div>
            <% end %>
            <hr/>
            <% unless @inputs.nil? %>
            <form role="form" method="POST" class="form-horizontal">
            <% for @input in @inputs %>
              <div class="form-group">
              <label class="col-sm-2 control-label" for="<%= @input.name %>">
                <%= @input.prompt %>
              </label>
              <div class="col-sm-8">
                <input type="text" class="form-control" name="<%= @input.name %>" autocomplete="off"/>
              </div>
              </div>
            <% end %>
            <div class="form-group">
              <div class="col-sm-offset-2 col-sm-8">
                <input class="btn btn-default" type="submit" value="Submit"/>
              </div>
            </div
            </form>
            <% end %>
          </div>
        </div>
        <div class="row">
          <div class="col-sm-offset-2 col-sm-8">
            <% for @item in @items %>
              <dl>
                <dt>
                <a href="<%= @item.href %>">
                  <%= @item.href %>
                </a>
                </dt>
                <% for datum in @item.data %>
                  <% unless datum.value.nil? %>
                    <dd>
                      <%= datum.prompt %>:
                      <strong><%= h(datum.value) %></strong>
                    </dd>
                  <% end %>
                <% end %>
                <% for link in @item.links %>
                  <dd>
                    <%= link.prompt %>:
                    <strong>
                      <a href="<%= link.href %>">
                        <%= link.href[0..28] %>...
                      </a>
                      </strong>
                    </dd>
                <% end %>
              </dl>
              <hr/>
              </body>
            <% end %>
            </div>
          </div>
        </div>
      </div>
    }
  end

  def render()
    ERB.new(@template).result(binding)
  end

end
