// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require cable
//= require_tree ./channels


console.log('this comes first. cable.js')
(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

}).call(this);
