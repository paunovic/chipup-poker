local hostname,port = ...

print("need to connect to "..hostname..":"..port)

local client1 = makeClient(hostname, port)
print("client1:",client1)
client1:connect()
client1:sendHello()
return true
