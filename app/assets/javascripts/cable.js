// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require cable



(function() {
  this.App || (this.App = {});
  console.log('inside cable setup')

  App.cable = ActionCable.createConsumer();

}).call(this);
