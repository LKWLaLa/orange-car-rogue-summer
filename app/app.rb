require 'redis'

redis = Redis.new(url: 'redis://redis:6379')
puts redis.ping

