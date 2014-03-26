#!/usr/bin/env ruby
# encoding: utf-8
script_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift script_dir
require 'logger'
require 'mongo'
require 'zapya_prepare_data'

batch = 100
source_coll = 'sharings.audio'
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
mapper = Mapper.pool(size:4)
recorder_number = db[source_coll].count
log.debug "记录数： #{recorder_number}"

futures = 0.step(recorder_number, batch).map { |offset|
	db_cursor = db[source_coll].find().skip(offset).limit(batch)
	mapper.future.map(db_cursor,offset)
}

sleep 100
futures.each do |f|
	log.info "user_item: #{f[0].size}   item_tag: #{f[1].size}"
end