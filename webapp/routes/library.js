// Chris Joakim, Microsoft, 2019/06/05

const express = require('express');
const router  = express.Router();

router.get('/', function(req, res) {
  var resp_obj = {};
  res.render('library', resp_obj);
});

router.get('/:bom_id', function(req, res) {
  var bom_id = '' + req.params.bom_id;
  console.log('bom_id: ' + bom_id);
  req.app.locals.dao.materialized_library_view(bom_id).then(function(result) {
    var data = result['result'][0];
    console.log(data);
    res.render('library', data);
  });
});

router.get('/show_bom/:bom_id', function(req, res) {
  var bom_id = '' + req.params.bom_id;
  var sess = req.session;
  sess.curr_bom_id = bom_id;
  res.redirect('/bom');
});


module.exports = router;
