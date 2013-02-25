/**
 * This file contains tests for query examples brought up in GH issues.
 * If you come up with a particularly devious query, please add it here and
 * send a pull request. :)
 */

var g = require('../../lib')

var test = require('tap').test

test("https://github.com/BetSmartMedia/gesundheit/issues/21", function (t) {
  var subselect = g.select('t1', [g.text('1')]).where({id: 3})
  var source = g.select('t1', [g.text("3, 'C', 'Z'")])
    .where(g.notExists(subselect))

  var insert = g.insert('t1', ['id', 'f1', 'f2']).from(source)

  t.equal(insert.render(),
    "INSERT INTO t1 (id, f1, f2) " +
    "SELECT 3, 'C', 'Z' FROM t1 WHERE NOT EXISTS " +
    "(SELECT 1 FROM t1 WHERE t1.id = ?)")
  t.end()
})

