// Learn more about the NJS syntax from the official documentation:
// https://nginx.org/en/docs/njs/reference.htm
//  https://nginx.org/en/docs/http/ngx_http_js_module.html

function foo(r) {
  r.warn("hello from foo() handler");

  // https://nginx.org/en/docs/njs/reference.html#core_global
  r.warn("ENV VARS currently available to Nginx:");
  // r.warn(njs.dump(process.env));
  ngx.log(ngx.INFO, njs.dump(process.env));

  var dest = process.env.PROJECT_DEST;
  return dest;
}

function getLocation(r) {
  // We still don't know how to use env vars, there's an object for them.
  // https://nginx.org/en/docs/njs/reference.html
  r.warn("Switching location");
  // process.env
  // Returns an object containing the user environment.

  return "meanwhile, in our universe !"

}

export default { foo, getLocation };
