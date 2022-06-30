# shapeshifter-dispatcher
### Unofficial Docker Image for shapeshifter-dispatcher

This is unofficial dockerized shapeshifter-dispatcher.  
The Shapeshifter project provides network protocol shapeshifting technology (also sometimes referred to as obfuscation).  
The purpose of this technology is to change the characteristics of network traffic so that it is not identified and subsequently blocked by network filtering devices.  
There are two components to Shapeshifter: transports and the dispatcher. Each transport provide different approach to shapeshifting.
The purpose of the dispatcher is to provide different proxy interfaces to using transports. Through the use of these proxies, application traffic can be sent over the network in a shapeshifted form that bypasses network filtering, allowing the application to work on networks where it would otherwise be blocked or heavily throttled.

![shapeshifter-dispatcher](https://raw.githubusercontent.com/MrKsey/shapeshifter-dispatcher/master/proxy_scheme_small.jpg)

More info:
- https://github.com/OperatorFoundation/shapeshifter-dispatcher
- https://github.com/OperatorFoundation/shapeshifter-transports

### Installing

- сreate "/state" directory (for example) on your docker host
- put ["config.ini"](https://raw.githubusercontent.com/MrKsey/shapeshifter-dispatcher/main/config.ini) file to "/state", set the desired options.
- connect host directory "/state" to the container directory "/state" and start container:
```
docker run --name shapeshifter-dispatcher -e TZ=Europe/Moscow -d --restart=unless-stopped --net=host -v /state:/state ksey/shapeshifter-dispatcher
```





