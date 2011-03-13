This file contains the steps needed to follow along with our BuildNight demo. Each step is also associated with a tag step_XX, where XX is the step number. Check out the tag and follow the steps to move on to the next step. If you make a mistake just checkout the next step and carry on!

    git checkout step_1

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
