// Chris Joakim, Microsoft, 2019/06/06

const express = require('express');
const router  = express.Router();
const request = require('request');
const events  = require('events');
const util    = require('util');
const fs      = require('fs');
const os      = require('os');

const D3CsvUtil = require('../util/d3_csv_util').D3CsvUtil;

router.get('/', function(req, res) {
  var sess = req.session;
  var resp_obj = {};
  if (sess.curr_bom_id) {
    resp_obj['bom_id'] = sess.curr_bom_id;
  }
  else {
    resp_obj['bom_id'] = 'tcx-js';
  }
  res.render('bom', resp_obj);
});

router.post('/', function(req, res) {
  var bom_id = req.body. bom_id;
  console.log('bom_router post / ' + bom_id);
  var sess = req.session;
  sess.curr_bom_id = bom_id;
  var resp_obj = {};
  resp_obj['bom_id'] = bom_id;
  res.render('bom', resp_obj);
});

router.get('/csv', function(req, res) {
  var sess = req.session;
  console.log('sess: ' + JSON.stringify(sess));

  if (sess.curr_bom_id) {
    var bom_id = sess.curr_bom_id.replace(/\//g, '|').trim(); // convert @azure/cosmos to @azure|cosmos
    var d3_util = new D3CsvUtil();
    console.log('bom_router get /csv ' + bom_id);
    req.app.locals.dao.gremlin_get_dep_graph(bom_id).then(function(result) {
      //console.log(result);
      var csv_lines = d3_util.gremlin_dep_graph_to_d3_csv(result);
      //console.log(csv_lines);
      res.set('Content-Type', 'text/csv');
      res.status(200).send(csv_lines);
    });
  }
  else {
    res.set('Content-Type', 'text/csv');
    res.status(200).send('');
  }
});

module.exports = router;
