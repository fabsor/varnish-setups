# Varnish configuration file for Pressflow/Drupal.
#
# By Thomas Barregren at NodeOne <http://nodeone.se/>.


/**
* Web server node-iweb01.
*/
backend web01 {
.host = "127.0.0.1";
.port = "8080";
.connect_timeout = 1m;
.first_byte_timeout = 1m;
.between_bytes_timeout = 10s;
}

/**
* Distribute backend calls by round robin.
*/
director web round-robin {
{ .backend = web01; }
}

/**
* Called at the beginning of a request, after the complete request has been
* received and parsed.
*/
sub vcl_recv {

// Load balance the requests.
set req.backend = web;

// Let requests for cron.php, install.php, update.php and xmlrpc.php
// pass through to the backend.
if (req.url ~ "^/(cron|install|update|xmlrpc)\.php") {
return (pass);
}

// Pass Flag module requests.
if (req.http.url ~ "^/flag/") {
return (pass);
}

// Pipe large media files to avoid overfilling cache.
if (req.url ~ "\.(mp3|mp4|ogg|mov|avi|wmv)$") {
return (pipe);
}

// Remove the Accept-Encoding header for already compressed files, and
// normalize it for other files to avoid duplicates in cache.
if (req.http.Accept-Encoding) {
if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|zip|rar|odt|ods|odp|odg|odf)$") {
remove req.http.Accept-Encoding;
}
elsif (req.http.Accept-Encoding ~ "gzip") {
set req.http.Accept-Encoding = "gzip";
}
elsif (req.http.Accept-Encoding ~ "deflate") {
set req.http.Accept-Encoding = "deflate";
}
else {
remove req.http.Accept-Encoding;
}
}

// Remove all cookies for anonymous requests and requests for static
// content, to allow caching.
if (req.http.url ~ "^/(misc|modules|profiles|sites|themes)/.*") {

// Requests beginning with misc/, modules/, profiles/, sites/ or themes/
// are a request for a static file. Remove all cookies to allow caching.
unset req.http.Cookie;

}
  elseif (!req.http.Cookie ~ "(^|;\s*)SESS[0-9a-f]{32}=[0-9a-f]{32}(;|$)") {
  // Requets without Drupal's session cookie are anonymous requests.
  // Remove all cookies to allow caching.
  unset req.http.Cookie;

  }

  // If backend is busy refreshing the requested object, Varnish will instead
  // deliver the expired object if it the time elapsed since expiration is
  // within the grace period set below.
  set req.grace = 5m;

}

/**
 * Called after a document has been successfully retrieved from the backend.
 */
sub vcl_fetch {
  // If backend isn't healthy, wait the grace period set below, and try again.
  // After max_restarts (default value: 4) tries, an error is returned.
  // This value should not be less than the grace period set in vcl_recv.
  if (obj.status != 200 && obj.status != 301 && obj.status != 302 && obj.status != 403 && obj.status != 404) {
    set req.grace = 15m;
    restart;
  }

  // Allow objects that have expired to remain in the cache during the grace
  // period set below. This grace period should be not less than req.grace,
  // set above, multiplied with max_restarts.
  set obj.grace = 60m;

  // Any request beginning with misc/, modules/, profiles/, sites/ or themes/
  // is a request for a static file.
  if (req.url ~ "^(misc|modules|profiles|sites|themes)/.*") {
    // Static files, such as JavaScript, CSS, images and uploaded files, don't
    // use cookies. Therefore, remove any cookies set by the backend.
    unset obj.http.set-cookie;
  }

}

/**
* Called before lookup to generate the hash key.
*/
sub vcl_hash {
  // Add any cookie to the hash.
  if (req.http.Cookie) {
  set req.hash += req.http.Cookie;
  }
}
