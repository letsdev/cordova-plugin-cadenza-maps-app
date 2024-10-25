var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var CMAppPlugin = function() {

};

CMAppPlugin.disableIdleTimeout = function(successCallback, failureCallback) {
	exec(successCallback, failureCallback, 'CMAppPlugin', 'disableIdleTimeout', []);
};

CMAppPlugin.enableIdleTimeout = function(successCallback, failureCallback) {
	exec(successCallback, failureCallback, 'CMAppPlugin', 'enableIdleTimeout', []);
};

CMAppPlugin.startMigration = function(cadenzaMobileTargetPath, successCallback, failureCallback) {
  exec(successCallback, failureCallback, 'CMAppPlugin', 'startMigration', [cadenzaMobileTargetPath]);
};

CMAppPlugin.convertFileToBase64 = function(filePath, successCallback, failureCallback) {
  exec(successCallback, failureCallback, 'CMAppPlugin', 'convertFileToBase64', [filePath]);
};

CMAppPlugin.exportFile = function(filePath, fileName, successCallback, failureCallback) {
  exec(successCallback, failureCallback, 'CMAppPlugin', 'exportFile', [filePath, fileName]);
};

CMAppPlugin.getCloudDirectory = function(successCallback, failureCallback) {
  exec(successCallback, failureCallback, 'CMAppPlugin', 'getCloudDirectory', []);
};

CMAppPlugin.startLocationManager = function(successCallback, failureCallback) {
  exec(successCallback, failureCallback, 'CMAppPlugin', 'startLocationManager', []);
};

CMAppPlugin.stopLocationManager = function(successCallback, failureCallback) {
  exec(successCallback, failureCallback, 'CMAppPlugin', 'stopLocationManager', []);
};

module.exports = CMAppPlugin;
