
/*
 * GET home page.
 */
var fs = require('fs');

exports.index = function(req, res){
  var book
    , chapter
    , transition
    , filename
    , indexJson;
    
  fs.readFile('public/개역개정/index.json', function(err, indexData) {
  
    indexJson = JSON.parse(indexData);
    if (req.query.book) {
      book = req.query.book;
      if (isNaN(parseInt(book))) {
        for (var index in indexJson) {
          if (indexJson[index] === book) {
            book = index;
            break;
          }
        }
      }
    } else {
      book = '1'
    }
    if (req.query.chapter) {
      chapter = req.query.chapter;
    } else {
      chapter = '1'
    }
    if (req.query.transition) {
      transition = req.query.transition;
    } else {
      transition = 'default'
    }
    filename = 'public/개역개정/' + book + '/' + chapter + '.json';
    
    fs.stat(filename, function(err, stat) {
      if (err == null) {
        fs.readFile(filename, function (err, data) {
          var json, verses;
          json = JSON.parse(data);
          title = json['title'].replace(/\[.+\]/,'');
          
          verses = {};
          for (var verse in json['verses']) {
            var content, contents;
            content = json['verses'][verse];
            contents = [];
            if (content.length > 128) {
              var a = content.slice(128, content.length);
              var p = a.search(' ') + 128;
              contents.push(content.slice(0, p));
              contents.push(content.slice(p, content.length));
            } else {
              contents.push(content);
            }
            
            var len = contents.length;
            for (var i = 0; i < len; i += 1) {
              verses[verse + '(' + String(i) + ')'] = contents[i];
            }
            
          }
             
          res.render('index', { title: title, verses: json['verses'], transition: transition, book: indexJson[book], chapter: chapter, booklist: indexJson});
        });
      } else {
        res.render('notfound', { title: 'Not Found', transition: transition, book: book, chapter: chapter, booklist: indexJson});
      }
    });
  });
  
};
