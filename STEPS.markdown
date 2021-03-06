This file contains the steps needed to follow along with our BuildNight demo. Each step is also associated with a tag step_XX, where XX is the step number. Check out the tag and follow the steps to move on to the next step. If you make a mistake just checkout the next step and carry on!

    git checkout step_1

Step 7 (step_7)
---------------
Now that we've got the basics working, let's add a little polish to our app.

The first thing we're going to do is update the standard layout used by our applicaiton to add a common header and footer with some basic navigation. The default layout used by the application is stored in app/views/layouts/application.html.erb. If you open it up right now, it will look something like this:

    <!DOCTYPE html>
    <html>
    <head>
      <title>Listsapp</title>
      <%= stylesheet_link_tag :all %>
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>
    </head>
    <body>

    <%= yield %>

    </body>
    </html>

The call to yield on line 11 is where the different contents of each page are rendered. Any HTML we add before or after that will appear on every page.

I won't go over all my changes, as we don't have time to cover HTML5 in this talk however we'll use standard HTML5 to add a header and footer. The final markup should now look like this:

    <!DOCTYPE html>
    <html>
    <head>
      <title>Listr</title>
      <%= stylesheet_link_tag :all %>
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>
    </head>
    <body>
      <div id="container">
        <header>
          <hgroup>
          <h1><%= link_to "Listr", root_url %></h1>
          <h2>These lists are winning!</h2>
          </hgroup>
        </header>
        <article>
          <%= yield %>
        </article>
        <footer>
        Built by <a href="http://twitter.com/scottbrooksca">@ScottBrooksCA</a> and <a href="http://twitter.com/MarkBennett">@MarkBennett</a> in front of a live studio audience during Edmonton's first BuildNight. <a href="https://github.com/yegrb/buildnight">Get the source on GitHub</a>.
        </footer>
      </div>
    </body>
    </html>

Tweak the prolog to your own liking! :)

We'll also update the Lists index:

    <ul>
      <% @lists.each do |list| %>
          <li><%= link_to list.title, list %></li>
      <% end %>
    </ul>
    <aside class="actions">
    <h2>Actions</h2>
    <ul>
      <li><%= link_to "New List", new_list_url %></li>
    </ul>
    </aside>

As well change `root :to` line in config/routes.rb to, `root, :to => "lists#index" and delete public/index.html. No visiting the root of your server will show an index of your Lists.

We've also added some basic cssreset borrowed from html5boilerplate.

Step 6 (step_6)
---------------
Lists aren't much use without some items to go them. We'll start by adding some items to our Lists in db/seeds.rb and then displaying them when we show a list.

First add some items to the seed data in db/seeds.rb:

    if Rails.env.development?
      groceries = List.create(:title => "Groceries")
      groceries.items.create(:text => "oranges")
      groceries.items.create(:text => "apples")
      groceries.items.create(:text => "crackers")
      groceries.items.create(:text => "wheatbix")

      errands = List.create(:title => "Errands")
      errands.items.create(:text => "get groceries")
      errands.items.create(:text => "pickup parcel")
      errands.items.create(:text => "wash the car")

      favs = List.create(:title => "Favourite Albums")
      favs.items.create(:text => "Tron: Legacy")
      favs.items.create(:text => "Reintegration Time")
      favs.items.create(:text => "Boxer")
      favs.items.create(:text => "The King is Dead")

      gems = List.create(:title => "Winning RubyGems")
      gems.items.create(:text => "rails")
      gems.items.create(:text => "sinatra")
      gems.items.create(:text => "rack")
      gems.items.create(:text => "bundler")
      gems.items.create(:text => "devise")
      gems.items.create(:text => "cancan")
    end

Load this up,

     bundle exec rake db:setup

And now change app/views/lists/show.html.erb to show a lists items:

  <h1><%= @list.title %></h1>
  <ul>
    <% @list.items.each do |item| %>
      <li><%= item.text %></li>
    <% end %>
  </ul>
  <%= link_to 'Edit', edit_list_url(@list) %>
  <%= link_to 'Destroy', list_url(@list), :method => :delete, :confirm => "Are you sure?" %>

Go back to your browser and now the lists are starting to look a bit better. Unfortunately, they're not much use if we can't edit the items on the list. Let's fix that!

We'll begin by creating a new nested resource for the Items associated with a List. Nested resources are resources (like our Items) which don't really make sense outside the context of another resource (the List). The classic example of a nested resource is blog comments. The comments are often modelled as a nested resource of an article.

To get started we'll add an items resource to our routing. Changing the `resources :lists` line in config/routes.rb to read:

    resources :lists do
      resources :items, :except => [:index, :show]
    end

If you display the routes again, you'll notice we've not got new urls to handle the items associated with a list:

    $ bundle exec rake routes

    list_items POST   /lists/:list_id/items(.:format)          {:action=>"create", :controller=>"items"}
 new_list_item GET    /lists/:list_id/items/new(.:format)      {:action=>"new", :controller=>"items"}
edit_list_item GET    /lists/:list_id/items/:id/edit(.:format) {:action=>"edit", :controller=>"items"}
     list_item PUT    /lists/:list_id/items/:id(.:format)      {:action=>"update", :controller=>"items"}
               DELETE /lists/:list_id/items/:id(.:format)      {:action=>"destroy", :controller=>"items"}

All these new routes expect a ItemsController so let's include that as well.

    $ bundle exec rails generate controller Items

I've left off the actions since none of them will need any views to go with them. All the editing will happen on the List's page.

To that effect, let's add a form to add new items to a list.  Open up app/views/lists/show.html.erb and add this form to the end of the items list:
    
    <li>
      <% form_for [@list, @new_item] do |f| %>
        <%= f.text_field :text, :placeholder => "new item..." %>
        <%= f.submit "Add" %>
      <% end %>
    </li>

Again we're using the form_for helper, but we for nested resources we must pass it an array of the nested resources instead. We'll also need to create @new_item in our ListsController. Change ListsController#show() to:

    def show
      @new_item = Item.new(:list => @list)
    end

You should now see this form when you view a List. If you try to submit you'll get and error indicating that ItemsController#create() is missing. Define that next.

    def create
      @list = List.find(params[:list_id])
      @new_item = Item.new(params[:item].merge({ :list => @list }))
      if @new_item.save
        flash[:notice] = "New item added"
        redirect_to @list
      else
        render :file => 'lists/show'
      end
    end

We'll also add some validation to our Item model:

  class Item < ActiveRecord::Base
    belongs_to :list
    validates_presence_of :text
  end

And display them on our form. Since this is similair to what we did before for the new lists we'll add a helper to re-use the same code. Helpers we want to use across the application belong in app/helpers/application_helpers.rb. Add this:

    module ApplicationHelper
      def errors_for(subject)
        render :partial => "shared/errors", :locals => { :subject => subject } 
      end
    end

We'll also need to add a new partial in app/views/shared/_errors.html.erb:

    <% if subject.errors.any? %>
    <div id="errorExplanation">
      <h2><%= pluralize(subject.errors.count, "error") %> prohibited this <%=subject.class.human_name.downcase %> from being saved:</h2>
      <ul>
      <% subject.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
    <% end %>

Now update your lists form (in app/views/lists/_form.html.erb) to use this helper:

    <%= errors_for @list %>
    <%= f.label :title %>
    <%= f.text_field :title %>

And add it to your the page showing an individual list (in app/views/lists/show.html.erb) on line 8:

    <h1><%= @list.title %></h1>
    <ul>
      <% @list.items.each do |item| %>
        <li><%= item.text %></li>
      <% end %>
      <li>
        <% form_for [@list, @new_item] do |f| %>
          <%= errors_for @new_item %>
          <%= f.text_field :text, :placeholder => "new item..." %>
          <%= f.submit "Add" %>
        <% end %>
      </li>
    </ul>
    <%= link_to 'Edit', edit_list_url(@list) %>
    <%= link_to 'Destroy', list_url(@list), :method => :delete, :confirm => "Are you sure?" %>

We can now create a new item. Let's follow the same pattern and allow you to edit items in the list. To do this we'll just change each list item into it's own form. Change the section in app/views/lists/show.html.erb which displays an item:

    <% @list.items.each do |item| %>
      <li>
        <% form_for [@list, item] do |f| %>
          <%= f.text_field :text %>
          <%= f.submit "Save" %>
        <% end %>
        <%= button_to "Remove", list_item_url(:list_id => @list.to_param, :id => item.to_param), :method => :delete %>
      </li>
    <% end %>

To handle this form we need to define ItemsController#update():

    def update
      @item = Item.find(params[:id])
      if @item.update_attributes(params[:item])
        flash[:notice] = "Item updated"
        redirect_to @list
      else
        flash[:error] = @item.errors.full_messages.join('. ')
        redirect_to @list
      end
    end

Since both the create() and update() actions need the @list set, we've also added a new filter to help out with this:

    class ItemsController < ApplicationController

      before_filter :load_list

      ... snip! ...

      private

      def load_list
        @list = List.find(params[:list_id])
      end
    end

Don't forget to remove the line from ItemsController#create() which sets @list.

We also need to add an ItemsController#destroy() method to handle the removing of items.

    def destroy
      @item = Item.find(params[:id])
      @item.destroy
      flash[:notice] = "Removed item"
      redirect_to @list
    end

We can now create, edit, and destroy items on a list!


Step 5 (step_5)
---------------
You may have tried creating a List with a blank title and noticed that it worked. Saving Lists without a blank title should never be allowed, and Rails provides and easy way to enforce this with ActiveRecord validations.

Open up the List model in app/models/list.rb and add `validates_presence of :title` on line 4:

    class List < ActiveRecord::Base
      has_many :items

      validates_presence_of :title
    end

This line now validates that a lists title is not blank when we call List#save() before storing it in the database. If the validation passes, then the list is stored, otherwise List#save() returns false. To find out why the validation failed we inspect List#errors. This is a set of Error objects, but we can see a human-readable array with List#errors.full_messages.

Let's try this out on the rails console console:

    $ bundle exec rails conosle
    > list = List.new
      => #<List id: nil, title: nil, created_at: nil, updated_at: nil>
    > list.save
      => false
    > list.errors
      => #<OrderedHash {:title=>["can't be blank"]}>
    > list.errors.full_messages
      => ["Title can't be blank"]

You can also call List#valid? to test if a model validates, without saving it.

    > list.valid?
      => false
    > list.title = "A new list"
      => "A new list"
    > list.save
      => true

Now that we've got validation working on the List model, we need to add support for it in the ListsController. Knowing that List#save() will return false if validation fails, we'll test the results of this call and re-display the form along with a notice of any validation errors that may come up.

Change the ListsController#create() method to:

    def create
      @list = List.new(params[:list])
      if @list.save
        flash[:notice] = "Created your new list!"
        redirect_to lists_url
      else
        render :new
      end
    end

And the ListsController#update() method to:

    def update
      if @list.update_attributes(params[:list])
        flash[:notice] = "Your list was updated!"
        redirect_to @list
      else
        render :edit
      end
    end

And then add some code to display the error messages in the list form partial in app/views/lists/_form.html.erb


    <% if @list.errors.any? %>
    <div id="errorExplanation">
      <h2><%= pluralize(@list.errors.count, "error") %> prohibited this list from being saved:</h2>
      <ul>
      <% @list.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
    <% end %>

    <%= f.label :title %>
    <%= f.text_field :title %>

Jump back to your web browser and give your validations a try!

Step 4 (step_4)
---------------
The controller layer receives HTTP requests from the Rails router and handles the request. The controller can then pass the results of the request to be rendered by the view.

We'll start by creating a ListsController to handle the Create, Retrieve, Update, and Destroy (CRUD) methods for the Lists in our application.

   bundle exec rails generate controller Lists index show new edit

This uses the Rails controller generator to create a new ListsController class, along with the associated view files, tests, and helpers. We'll explore each of these files later.

Before we try out our new controller we also need to update the routing.

Open config/routes.rb and replace all these lines,

    get "lists/index"
  
    get "lists/show"
  
    get "lists/new"
  
    get "lists/edit"

with,

    resources :lists

To see the url's your application will route to your new ListsController try entering:

    bundle exec rake routes

You'll see something like this:

    lists GET    /lists(.:format)          {:action=>"index", :controller=>"lists"}
          POST   /lists(.:format)          {:action=>"create", :controller=>"lists"}
 new_list GET    /lists/new(.:format)      {:action=>"new", :controller=>"lists"}
edit_list GET    /lists/:id/edit(.:format) {:action=>"edit", :controller=>"lists"}
     list GET    /lists/:id(.:format)      {:action=>"show", :controller=>"lists"}
          PUT    /lists/:id(.:format)      {:action=>"update", :controller=>"lists"}
          DELETE /lists/:id(.:format)      {:action=>"destroy", :controller=>"lists"}

Each line starts with the name of the route, then the HTTP method it responds to and an example of the url. Elements in paranthesis are optional, and named params start with a colon. You'll see how to use the parameters later.

Following the path is the name of the controller responsible for this path, and the name of the method on the controller which will be invoked (called the :action).

Let's go to the index in our web browser. Navigate to http://localhost:3000/lists and you should see a blank template. As the page suggests we need to add our HTML to /app/views/lists/index.html.erb. Drop this HTML into the page:

    <h1>Lists</h1>
    <table>
      <caption>Lists</caption>
      <thead>
        <tr>
          <th>Title</th>
        </tr>
      </thead>
      <tbody>
        <% @lists.each do |list| %>
          <tr>
            <td><%= list.title %></td>
          </tr>
        <% end %>
      </tbody>
    </table>

The Ruby litterred throughout iterates over a set of lists and display each in a table row. For this to work we'll also need to load up all the lists in our application and assign them to a instance variable called @lists. We should do this in the ListsController. Open up app/controllers/lists_controller.rb and change the ListsController#index method to:

    def index
      @lists = List.all
    end

Before we'll see any Lists we'll also need to add some to our database. You use the db/seed.rb file to load data into your environment. In development it's ok to create sample data this way, though in the production you'll normally only run it once to setup admin accounts or to load constants into your database. Open our db/seeds.rb and add:

    if Rails.env.development?
      List.create(:title => "Groceries")
      List.create(:title => "Errands")
      List.create(:title => "Favourite Albums")
      List.create(:title => "Winning RubyGems")
    end

To recreate your database populate it with fresh data run:

    bundle exec rake db:setup

You can do this whenever you want and it's a great way to get a dev box up and running quickly.

Now reload your web browser and you'll see these new lists on the index.

We'll follow this same pattern to update the rest of the methods in the ListsController:

    class ListsController < ApplicationController

      before_filter :load_object, :only => [:show, :edit, :update, :destroy]

      def index
        @lists = List.all
      end

      def show
      end

      def new
        @list = List.new
      end

      def create
        @list = List.new(params[:list])
        @list.save
        flash[:notice] = "Created your new list!"
        redirect_to lists_url
      end

      def edit
      end

      def update
        @list.update_attributes(params[:list])
        flash[:notice] = "Your list was updated!"
        redirect_to @list
      end

      def destroy
        @list.destroy
        flash[:notice] = "List removed"
        redirect_to lists_url
      end

      private

      def load_object
        @list = List.find(params[:id])
      end

    end

There's a lot going on here so let's go through it method by method.

At the top we add a before_filter. Filters are methods which are run before an action is called. In this case before the show, edit, update, and destroy actions were going to call the load_object method. This takes the id parameter from our url and loads up the corresponding List into the @list instance variable. Don't Repeat Yourself, or DRY, is one of the core tenants of Rails development and we try to emulate that in our own code. Filters just make that easier!

Moving on to the ListController#show() method, we don't really have to do anything since the before_filter has already loaded our object. By default this method will try to render our view in app/views/lists/show.html.erb so there's nothing else we need to do in this method. Easy!

ListController#new() does a little more and simply creates a new List before rendering app/views/lists/new.html.erb. Though the new List is empty by default now, it could need to be pre-populated or associated with other objects in the future. This is where we would do that.

Things start to get interesting in ListController#create(). This action is called when you POST the new list form. When executed the contents of params are:

  {
    :list => { :title => "My new list" }
  }

The first line creates a new List from the contents of params[:list]. In this case that sets the title of the new list to "My new list". We save the new list and flash a notification message to the user indicating the list was created. To finish we redirect them back to the index where they see their new List along with all the others.

ListsController#edit() works just like ListsController#show(). The @list is loaded by the filter and then app/views/lists/edit.html.erb is rendered automatically.

ListsController#update() is similair to ListsController#create(). The @list is loaded by the filter, and then we call @list.update_attributes() instead of save() to update the title. A notice is flashed, and we redirect the user back to the updated list.

The last action we'll look at is ListsController#destroy(). This takes a @List and removes it from the database and our application. To do so, we just call @list.destroy() and then flash a notice that the list is gone before redirecting the user back to the index.

That covers the ListsController, so what about the HTML in the views?

Here's what we're got in the show view (app/views/lists/show.html.erb)

    <h1><%= @list.title %></h1>
    <p><b>TODO</b>: Add some items!</p>
    <%= link_to 'Edit', edit_list_url(@list) %>
    <%= link_to 'Destroy', list_url(@list), :method => :delete, :confirm => "Are you sure?" %>

The first line displays the title of the list in a `h1`. The second-line is self-evident. The third uses the link_to() method which creates a link labelled edit and pointing to the url returned edit_list_url(@list). The name of this url method comes from the routes in our application. Look at the routes again:

    bundle exec rake routes

Notice the `edit_list` line? Add `_url` to the end of `edit_list` to get either `edit_list_url` which return a url you can use to link together resources in your application. This also works for `lists_url`, `new_list_url`, and `list_url`! If the url has an :id parameter in it, you'll also want to specify the @list you want to generate the url for. This is what we're doing on the third line when we use `edit_list_url(@list)`.

The link_to() destroy on the last line also accepts a method of :delete and a confirmation message to display when clicked. If you look in the routes again you'll see this route linked to the ListsController#destroy() action.

Moving on to `app/views/lists/new.html.erb`, this view display a form for editing a new List.

    <h1>New List</h1>

    <% form_for @list do |f| %>
      <%= render :partial=>'form', :locals=>{:f=>f} %>
      <%= f.submit 'Create' %>
    <% end %>

On line 3, we use the form_for() method which renders an HTML form for the new @list we created in the controller. As @list is a new record, form_for automatically knows the form should submit to the controllers create action.

The lines inside the form_for() are interesting. Rails provides a feature called view partials, which render content from another file. Variables from this view aren't automatically passed through from this file to the partial, so we use the :locals option to pass through the ones we're interested in. In this case, it's a reference to our form.

The partial itself is in `app/views/lists/_form.html.erb`. Notice it's the same as the name that was passed into render() with the :partial option, only with an underscore at the start. The contents of the partial look like this:

    <%= f.label :title %>
    <%= f.text_field :title %>

This takes the form passed it, and renders a label for the lists title attribute, and then a text field to edit it.

Going back to the new form we finish off with a call to the `f.submit` method. This adds a submit button labelled "Create" to the bottom of the form. We didn't include this in the partial as we'll be re-using the partial again on the edit form where calling it "Create" won't make much sense.

There's no HTML associated with the create action, so we'll move on to the edit form. It's located in `app/views/lists/edit.html.erb` and should contain:

    <h1>Edit List</h1>

    <% form_for @list do |f| %>
      <%= render :partial=>'form', :locals=>{:f=>f} %>
      <%= f.submit 'Edit' %>
    <% end %>

Except for the use of the word "Edit" instead of "Create" this looks a lot like the new form and even uses the same partial. Remember, Don't Repeat Yourself!

The update and destroy actions don't have any associated HTML with them so that's it. We're done the ListsController. Or are we?

Step 3 (step_3)
---------------
The model layer in our application is responsible for capturing our business logic and data. The contents of this layer shouldn't contain HTML, JavaScript or view code which will be implemented seperately in the views and controllers.

Out of the box Ruby on Rails uses ActiveRecord to store and retrieve objects in the database. There are other Object Relational Mappers (ORM's) besides ActiveRecord which also work with Ruby but we won't be covering those here.

The first object we'll add to our model represents a List. Lists are simple, and for the time being will only have a name associated with them. We'll use a Rails generator to setup the model for us.

    bundle exec rails generate model list title:string

This generator creates a ruby class to represent our list as well as a set of tests, and the database migrations to add a lists table with a title column to our database. To run this migration and create the table in our development database we'll use a command-line tool called rake.

    bundle exec rake db:create db:migrate

Rake is a standard ruby tool used by many projects to automate system tasks from the command-line.

To see this model in action we'll spin up the rails console:

    bundle exec rails console

The console is a great tool, which allows you to interactively explore your application. All your models are automatically loaded and available to you through an interactive terminal console similair to irb.

Try out some of these commands in the rails console and see what happens:

   > List
   > groceries = List.create(:title => "Groceries")
   > List.count

Now that we've created the List model, let's create some Items to go with it.

ActiveRecord models can be related to each other. ActiveRecord provides three different kinds of relationships:

 1. `belongs_to` - indicates an instance of this model is owned by another model
 2. `has_one` - indicates this model owns another model
 3. `has_many` - indicates this models owns many of another model
 4. `has_many :through` - this is a special case of a has_many relationship, which indicates that one model has many of another model through a relationship with an intermediate model. It's useful during cases were it's important to capture information about the relationship between to models, such as wehen the relationship was created or by whom.

In this case our List model has_many Items, and each Item belongs_to one List.

Now that the relationship between our models is clear, lets use the Rails model generator to create our new Item model.

    bundle exec rails generate model item text:string list_id:integer

Change the generated code in app/models/item.rb to add a relationship to it's list:

    class Item < ActiveRecord::Base
      belongs_to :list
    end

We'll also indicate that a List has many Items. Edit app/models/list.rb:

    class List < ActiveRecord::Base
      has_many :items
    end

Finally run your database migrations:

    bundle exec rake db:migrate

Now let's hitup the rails console and try this relationship out:

    bundle exec rails console

In the console try:

    > List.count                                      # 1
    > groceries = List.find_by_title("Groceries")     # returns the list you created previously
    > groceries.items                                 # []
    > groceries.items.create(:text => "apples")
    > groceries.items.create(:text => "oranges")
    > groceries.items

Great work, the model is ready to go!

Step 2 (step_2)
----------------
In this step we'll setup bundler so we're ready to run the app. Bundler is a Ruby gem for managing different versions of gems installed on your system. It helps you make sure that same versions of different gems are always used with your project, even on different machines. The list of gems your application uses is stored in a `Gemfile`. This describes the gems, but normally leaves our the specific version. Bundler looks at your dependencies and figures out the latest version that will satisfy all the dependencies in your Gemfile. It then makes these gems available to your app, and stores the specific versions it installed in another file called Gemfile.lock. You'll want to check both of these files into your version control.

To get Bundler to install all the gems for your new app, enter:

    bundle install

Once your gems are installed our app is ready to run! You can launch your app using the `rails` command-line tool.

    bundle exec rails server

Go to http://localhost:3000 to see what you've created!


Step 1 (step_1)
----------------
Begin my installing Rails 3 if you haven't already.

    gem install rails

This will take a few minutes to download and install the documentation locally. Ruby uses a systems called RubyGems to share and distribute code amongst the community. There are thousands of gems available, of which Rails is only one example. The gems themselves are hosted publicly on [[RubyGems.org|http://rubygems.org]].

Once the Rails gem is installed a new `rails` command-line tool is available. This is your your main way of working with your Rails app.

We'll be building a simple application to manage and share a shopping list. Rails applications follow a standard convention for their directory and file structure. This convention ensures all Rails apps have a familiar structure and are easy to navigate once you've learned the convention. To create our new app type:

    rails new listsapp

Rails will tell you what it's doing as it goes along. Once it's done a new **listsapp** directory will be created. Change into this and take a look around. Once you're done move on to the next step.

    cd listsapp
    ls

Step 0 (step_0)
----------------

To get started follow the [[directions on our wiki|https://github.com/yegrb/yeg-wiki/wiki/Installing-Ruby]] to install and setup Ruby on your machine. 

Verify you've got it installed properly by typing this at your console:

    ruby -v

You should have at least Ruby 1.8.7 installed.
