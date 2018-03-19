require 'redis'
require 'rest-client'

def collect_values_from_redis
  redis = Redis.new(url: 'redis://redis:6379')
  redis.keys.map do |k| 
    if redis.type(k) == "list"
      redis.lrange(k, 0, -1)
    elsif redis.type(k) == "set"
      redis.smembers(k) 
    else
      next
    end
  end
end

def no_anagrams?(collection)
  sorted_collection = collection.map {|num_str| num_str.chars.sort.join}
  sorted_collection.uniq.length == collection.length
end

def anagram_free_collections
  collect_values_from_redis().select {|c| no_anagrams?(c)}
end

def differences_collection
  int_collections = anagram_free_collections().map do |c|
    c.map{|num_str| num_str.to_i}
  end
  int_collections.map{|c| c.max - c.min}
end

def send_checksum
  checksum = differences_collection().reduce(:+) 
  puts "The checksum is #{checksum}."  
  puts RestClient.get("http://answer:3000/#{checksum}")
end

send_checksum()


