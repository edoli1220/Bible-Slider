
fs = require 'fs'
async = require 'async'

exports.bible = (data) ->
  fs.readFile 'public/개역개정/index.json', (err, indexData) ->
  
    indexJson = JSON.parse indexData

    if data.book 
      book = data.book
      if isNaN parseInt book
        for index, value of indexJson
          if value is book
            book = index
            break
    else
      book = '1'
    
    chapter = if data.chapter then data.chapter else '1'
    transition = if data.transition then data.transition else 'default'
    
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
          #do something

      (data, callback) ->
          json = JSON.parse data
          title = json['title'].replace /\[.+\]/, ''
          
          verses = {}

          start_verse = parseInt data.start_verse 
          end_verse = parseInt data.end_verse + 1

          for i in [start_verse .. end_verse]
            verses[i] = json['verses'][i.toString()]

          data.verses = verses
      ], (err, result) ->
        console.log err
