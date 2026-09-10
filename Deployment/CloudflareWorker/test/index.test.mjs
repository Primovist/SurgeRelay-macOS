import test from "node:test";
import assert from "node:assert/strict";
import { contentTypeForPath, resolveRepositoryPath } from "../src/index.js";

test("allows canonical module, airport, and generated asset paths", () => {
  assert.equal(resolveRepositoryPath("/modules/test.sgmodule"), "modules/test.sgmodule");
  assert.equal(resolveRepositoryPath("/airports/test.proxies"), "airports/test.proxies");
  assert.equal(resolveRepositoryPath("/airports/%E6%B5%8B%E8%AF%95%E6%9C%BA%E5%9C%BA.proxies"), "airports/测试机场.proxies");
  assert.equal(resolveRepositoryPath("/modules/assets/test.js"), "modules/assets/test.js");
});

test("maps legacy module URLs without changing canonical airport paths", () => {
  assert.equal(resolveRepositoryPath("/test.sgmodule"), "modules/test.sgmodule");
  assert.equal(resolveRepositoryPath("/assets/test.js"), "modules/assets/test.js");
});

test("rejects traversal and unsupported resource families", () => {
  assert.equal(resolveRepositoryPath("/../../xxx"), null);
  assert.equal(resolveRepositoryPath("/airports/%2e%2e/xxx.proxies"), null);
  assert.equal(resolveRepositoryPath("/airports/a%2Fb.proxies"), null);
  assert.equal(resolveRepositoryPath("/random/file"), null);
  assert.equal(resolveRepositoryPath("/modules/airports/test.proxies"), null);
});

test("uses explicit UTF-8 content types", () => {
  assert.equal(contentTypeForPath("airports/test.proxies"), "text/plain; charset=utf-8");
  assert.equal(contentTypeForPath("modules/test.sgmodule"), "text/plain; charset=utf-8");
  assert.equal(contentTypeForPath("modules/assets/test.js"), "application/javascript; charset=utf-8");
});
