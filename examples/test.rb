$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "request_pool"
require "pry"

servers = [
  "https://gjwet.dsgkwt.com",
  #"https://www.google.com.hk",
  #"http://www.facebook.com",
  #"http://testing.caishuo.com",
  "localhost:3000",
  #"https://www.baidu.com",
  #"http://baobao.caishuo-testing.com:8080"
]

client1 = RequestPool.new(servers) do |config|
  config.timeout = 50000
end

t = -> {Time.now}

#st = t[]
#100_000.times { client1.servers.convert_server rescue next }
#p t[] - st

client1.get("/topics", {}) { |config| config.timeout = 3000 }

