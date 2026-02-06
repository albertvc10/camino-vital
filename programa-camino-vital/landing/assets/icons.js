(function() {
  'use strict';
  var request = new XMLHttpRequest();
  request.open('GET', 'assets/icons.svg?v=2', true);
  request.onload = function() {
    if (request.status >= 200 && request.status < 400) {
      var div = document.createElement('div');
      div.setAttribute('hidden', '');
      div.setAttribute('aria-hidden', 'true');
      div.style.position = 'absolute';
      div.style.width = '0';
      div.style.height = '0';
      div.style.overflow = 'hidden';
      div.innerHTML = request.responseText;
      document.body.insertBefore(div, document.body.firstChild);
    }
  };
  request.send();
})();
