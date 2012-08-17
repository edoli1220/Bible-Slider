
fs = require 'fs'
async = require 'async'

exports.bible = (sdata, callback) ->
  fs.readFile 'public/개역개정/index.json', (err, indexData) ->
  
    indexJson = JSON.parse indexData

    if sdata.book 
      book = sdata.book
      if isNaN parseInt book
        for index, value of indexJson
          if value is book
            book = index
            break
    else
      book = '1'
    
    chapter = if sdata.chapter then sdata.chapter else '1'
    transition = if sdata.transition then sdata.transition else 'default'
    
    filename = 'public/개역개정/' + book + '/' + chapter + '.json'
    
    queues = [
      (callback) -> 
        fs.stat filename, (err, stat) ->
          callback(null, stat)

      (stat, callback) ->
        if stat
          fs.readFile filename, (err, data) ->
            callback(err, data)
        else
          callback("not found", data)

      (data, callback) ->
        json = JSON.parse data
        title = json['title'].replace /\[.+\]/, ''
        
        verses = {}

        start_verse = parseInt sdata.start_verse 
        end_verse = parseInt sdata.end_verse

        for i in [start_verse .. end_verse]
          verses[i] = json['verses'][i.toString()]

        sdata.verses = verses

        callback(null, 21)
    ]

    async.waterfall queues, (err, result) ->
      console.log err if err
      callback(err, result)

exports.hymn = (sdata, callback) ->
  chapter = if sdata.chapter then sdata.chapter else '1'
  transition = if sdata.transition then sdata.transition else 'default'
  
  filename = 'public/찬송가/' + chapter + '.json'
  
  queues = [
    (callback) -> 
      fs.stat filename, (err, stat) ->
        callback(err, stat)

    (stat, callback) ->
      if stat
        fs.readFile filename, (err, data) ->
          callback(null, data)
      else
        callback("not found", data)

    (data, callback) ->
      json = JSON.parse data
      title = json['title'].replace /\[.+\]/, ''

      sdata.verses = json['verses']
      callback(null, 21)
  ]

  async.waterfall queues, (err, result) ->
    console.log err if err
    callback(err, result)

exports.customscreen = (sdata, callback) ->
  callback(null, 21)

exports.lord_prayer = (sdata, callback) ->
  callback(null, 21)

exports.apostolic_creed = (sdata, callback) ->
  callback(null, 21)

exports.blackscreen = (sdata, callback) ->
  callback(null, 21)