This file contains the steps needed to follow along with our BuildNight demo. Each step is also associated with a tag step_XX, where XX is the step number. Check out the tag and follow the steps to move on to the next step. If you make a mistake just checkout the next step and carry on!

    git checkout step_1

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
