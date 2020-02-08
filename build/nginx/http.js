// https://nginx.org/en/docs/http/ngx_http_js_module.html

function foo(r) {
  r.warn("hello from foo() handler");
  return "foo";
}

function getLocation(r) {
  // We still don't know how to use env vars, there's an object for them.
  // https://nginx.org/en/docs/njs/reference.html
  r.warn("Switching location");
  // process.env
  // Returns an object containing the user environment.

  return "meanwhile, in our universe !"

}
