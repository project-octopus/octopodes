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
    @template = %{
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8"></meta>
        <title>Project Octopus <%= @title %></title>
        <link rel="icon" type="image/x-icon" href="/favicon.ico" />
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
      <nav class="navbar" role="navigation">
        <div class="container-fluid">
          <div class="navbar-header">
            <a class="navbar-brand" href="/">
              <img height="23px" src="/assets/octopus.png"/>
            </a>
          </div>
          <ul class="nav navbar-nav">
          <li>
          <a href="/">Project Octopus - Showing the use of creative works, one URL at a time.</a>
          </li>
          </ul>
        </div>
      </nav>
      <div class="container-fluid">
        <div class="row">
          <div class="col-sm-10 col-sm-offset-2">
            <ul class="nav nav-tabs">
              <li><a href="/">Home</a></li>
              <li><a href="/reviews">Works</a></li>
              <li><a href="/registrations">Register</a></li>
            </ul>
          </div>
        </div>
        <div class="row">
          <div class="col-sm-8 col-sm-offset-2">
            <h6><%= @title %></h6>
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
            <% unless @inputs.nil? %>
            <form role="form" method="POST" class="form-horizontal">
            <% for @input in @inputs %>
              <% @type = @input.name == "password" ? "password" : "text" %>
              <div class="form-group">
              <label class="col-sm-2 control-label" for="<%= @input.name %>">
                <%= @input.prompt %>
              </label>
              <div class="col-sm-8">
                <input type="<%= @type %>" class="form-control" name="<%= @input.name %>" autocomplete="off"/>
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
