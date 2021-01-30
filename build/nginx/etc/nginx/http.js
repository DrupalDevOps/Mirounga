// Learn more about the NJS syntax from the official documentation:
// https://nginx.org/en/docs/njs/reference.htm
// https://nginx.org/en/docs/http/ngx_http_js_module.html

function projectDestination(r) {
  // r.warn("hello from projectDestination() handler");

  var dest = process.env.PROJECT_DEST;
  return dest;
}

function debugEnvVars(r) {
  // Request object reference.
  // https://nginx.org/en/docs/njs/reference.html

  // https://nginx.org/en/docs/njs/reference.html#core_global
  ngx.log(ngx.INFO, njs.dump(process.env));

  return "meanwhile, in our universe !"
}

export default { projectDestination, debugEnvVars };
