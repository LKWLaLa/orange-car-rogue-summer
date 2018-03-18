require 'redis'
require 'rest-client'

redis = Redis.new(url: 'redis://redis:6379')

collections = redis.keys.map do |k| 
  if redis.type(k) == "list"
    redis.lrange(k, 0, -1)
  elsif redis.type(k) == "set"
    redis.smembers(k) 
  else
    next
  end
end

def no_anagrams?(collection)
  sorted_collection = collection.map {|item| item.chars.sort.join}
  sorted_collection.uniq.length == collection.length
end

anagram_free_collections = collections.select {|c| no_anagrams?(c)}

integer_collections = anagram_free_collections.map do |c|
  c.map{|num_string| num_string.to_i }
end

differences = integer_collections.map{|c| c.max - c.min}

checksum = differences.reduce(:+)   

puts RestClient.get("http://answer:3000/#{checksum}")

