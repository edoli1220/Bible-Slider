#GET home page.
fs = require 'fs'
async = require 'async'
sb = require './sb'

exports.index = (req, res) ->
  context = 
    title: 'Bible Slider'
  res.render "index", context

exports.lordPrayer = (req, res) ->
  context = 
    title: '주기도문'
  res.render "lord_prayer", context

exports.apostolicCreed = (req, res) ->
  context = 
    title: '사도신경'
  res.render "apostolic_creed", context

exports.bible = (req, res) ->    
  fs.readFile 'public/개역개정/index.json', (err, indexData) ->
  
    indexJson = JSON.parse indexData

    if req.query.book 
      book = req.query.book
      if isNaN parseInt book
        for index, value of indexJson
          if value is book
            book = index
            break
    else
      book = '1'
    
    chapter = if req.query.chapter then req.query.chapter else '1'
    transition = if req.query.transition then req.query.transition else 'default'
    
    filename = 'public/개역개정/' + book + '/' + chapter + '.json'
    
    async.waterfall [
      (callback) -> 
        fs.stat filename, (err, stat) ->
          callback(null, stat)

      (stat, callback) ->
        if stat
          fs.readFile filename, (err, data) ->
            callback(err, data)
        else
          context =
            title: 'Not Found'
            transition: transition
            book: book
            chapter: chapter
            booklist: indexJson
            type: "bible"
          res.render 'notfound', context

      (data, callback) ->
          json = JSON.parse data
          title = json['title'].replace /\[.+\]/, ''
          
          verses = {}

          context =
            title: title
            verses: json['verses']
            transition: transition
            book: indexJson[book]
            chapter: chapter
            booklist: indexJson
            type: "bible"
          res.render 'bible', context;
      ], (err, result) ->
        console.log err
        
  
exports.hymn = (req, res) ->    
  chapter = if req.query.chapter then req.query.chapter else '1'
  transition = if req.query.transition then req.query.transition else 'default'
  
  filename = 'public/찬송가/' + chapter + '.json'
  
  async.waterfall [
    (callback) -> 
      fs.stat filename, (err, stat) ->
        callback(err, stat)

    (stat, callback) ->
      if stat
        fs.readFile filename, (err, data) ->
          callback(null, data)
      else
        context =
          title: 'Not Found'
          transition: transition
          chapter: chapter
          type: "hymn"
        res.render 'notfound', context

    (data, callback) ->
        json = JSON.parse data
        title = json['title'].replace /\[.+\]/, ''
      
        context =
          title: title
          verses: json['verses']
          transition: transition
          chapter: chapter
          type: "hymn"
        res.render 'hymn', context;
    ], (err, result) ->
      console.log err



exports.builder = (req, res) ->
  fs.readFile 'public/개역개정/index.json', (err, indexData) ->
    indexJson = JSON.parse indexData
    context = 
      title: '프리젠테이션'
      booklist: indexJson
      bookIndex: indexData
    res.render "builder", context
  
exports.presentation = (req, res) ->
  reqList = JSON.parse(req.query.data)
  
  today = new Date;
  strDate = today.toString().slice(0,24).split(/\s/).join('').split(':').join('-')

  fs.writeFile 'public/presentations/' + strDate + '.txt', req.query.data, "utf-8", (err, data) ->
    console.log 'write finish'

  queues = []
  sdatas = []
  i = -1
  for sdata in reqList
    sdata.transition = "default"
    sdatas.push(sdata)
    queues.push (callback) ->
      i += 1
      sdata = sdatas[i]
      sb[sdata.type] sdata, callback

  series = 
    one: (callback) -> 
      async.parallel queues, (err, result) ->
        console.log err if err
        callback err, 1
    two: (callback) -> 
      context =
        title: 'presentation'
        dataList: reqList
      res.render 'presentation', context
      callback null, 1

  async.series series, (err, result) ->
    console.log err if err
    if err
      if err.errno is 34
        context =
          title: 'Not Found'
          transition: "default"
          chapter: "1"
          type: "hymn"
        res.render 'notfound', context
  
