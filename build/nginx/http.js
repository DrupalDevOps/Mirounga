// https://nginx.org/en/docs/http/ngx_http_js_module.html

function foo(r) {
  r.log("hello from foo() handler");
  return "foo";
}
