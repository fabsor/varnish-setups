# Varnish configuration file for Pressflow/Drupal.
#

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
 * Called at the beginning of a request, after the complete request has been
 * received and parsed.
 */
sub vcl_recv {

  // Load balance the requests.
  set req.backend = web01;

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
  elseif (!req.http.Cookie ~ "(^|;\s*)SESS[0-9a-f]{32}=([0-9a-zA-Z_-]{32}|[0-9a-zA-Z_-]{43})(;|$)") {
 
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
  if (beresp.status != 200 && beresp.status != 301 && beresp.status != 302 && beresp.status != 403 && beresp.status != 404) {
    set req.grace = 15m;
    restart;
  }

  // Allow objects that have expired to remain in the cache during the grace
  // period set below. This grace period should be not less than req.grace,
  // set above, multiplied with max_restarts.
  set beresp.grace = 60m;

  // Any request beginning with misc/, modules/, profiles/, sites/ or themes/
  // is a request for a static file.
  if (req.url ~ "^(misc|modules|profiles|sites|themes)/.*") {

    // Static files, such as JavaScript, CSS, images and uploaded files, don't
    // use cookies. Therefore, remove any cookies set by the backend.
    unset beresp.http.set-cookie;
    #set resp.http.X-Cache = "HIT";

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

sub vcl_deliver {
   // Add cache hit data.
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
    set resp.http.X-Cache-Hits = obj.hits;
  }
  else {
    set resp.http.X-Cache = "MISS";
  }
}
