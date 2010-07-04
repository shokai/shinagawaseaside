#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'tokyotyrant'
include TokyoTyrant
require 'yaml'

begin
  conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')
rescue
  STDERR.puts 'config.yaml load error'
  exit 1
end

dbs = Hash.new
conf['ttdb'].each{|db|
  puts "open #{db['name']}"
  rdb = RDB::new
  if !rdb.open('127.0.0.1', db['port'].to_i)
    STDERR.puts 'error - tokyotyrant : '+rdb.errmsg(rdb.ecode)
    exit 1
  else
    dbs[db['name'].to_sym] = rdb
  end
}

dbs[:users][1] = 'shokai'
dbs[:users][2] = 'hashimoto'

puts dbs[:users][1]

dbs[:users].keys.sort.each{|k|
  puts "#{k} => #{dbs[:users][k]}"
}



for i in 0...10 do
  dbs[:videos][i] = "#{rand(100)}.mov"
end

dbs[:videos].keys.sort.each{|k|
  puts "#{k} => #{dbs[:videos][k]}"
}


dbs.each{|name,rdb|
  puts "close #{name}"
  if !rdb.close
    STDERR.puts 'error - tokyotyrant : '+rdb.errmsg(rdb.ecode)
  end
}

