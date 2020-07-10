# README

IRIS Backend Task
A Shopping app where User can upload items to sell and make requests.(Upload Images of items too)
 
 Github Link-https://github.com/VithikShah/Shopping-App-IRIS
 ruby-2.5.1
 rails-5.2.2
 Steps-
 1.Clone the repo
 2.Change the password in config/databse.yml to your mysql password
 3. Run "bundle install"
 3.Execute "rake db:create" and then "rake db:migrate"
 4.In the web browser type " localhost:3000"
 
 *Note*-Run "sudo apt-get install imagemagick" only if the images are not visible
 
 Implemented Features:
 1.Adding images using ActiveStorage
 2.Presentation of images using bxslider-rails gem
 3.Search option for Category field(only restricted to one and exact word but case insensitive)
 4.Frontend Validation in Forms
 
 Working:
 After Signing Up
 1.Click on "New Shop" to upload an item to sell
 2.Click on "Go To Things On Sale" to see the items in the shop by other users and then click on "Show" to view the particular item and its images
 3.Click on "Manage Requests to request anb item"
 4.Click on "Request"  to see items requested by people
 
 References-
 1.https://rubygems.org/
 2.https://github.com/rails/rails/tree/master/activestorage
 3.https://github.com/stevenwanderski/bxslider-4
 
