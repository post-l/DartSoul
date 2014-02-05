
chrome.app.runtime.onLaunched.addListener(function(launchData) {
  chrome.app.window.create('dartsoul.html', {
    'id': '_mainWindow', 'bounds': {'width': 300, 'height': 475},
    'frame': 'none'
  });
});
