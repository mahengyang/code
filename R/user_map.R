library(rJava)
library(rredis)
library(ggmap)
library(mapproj)

### connect to redis,get all geohash code 
lbsDb <- 15
redisConnect(host='LDKJSERVER0006',port=6380,timeout=10)
redisSelect(lbsDb)
geohash <- redisKeys('a:*')
geohash <- sapply(geohash,redisSCard)
geohashCode <- strsplit(names(geohash),split=':')
#lbsData <- sapply(lbsData,function(x){ x[2] })
geohashCode <- sapply(geohashCode, '[', 2)
lbsData <- data.frame(code=geohashCode, number=geohash)

### call Geohash class to decode geohash
.jinit()
.jaddClassPath('e:/r/geohash.jar')
#apply(lbsData,1,)
lbsData <- do.call(rbind, apply(lbsData,1,function(x){ 
  location <- .jcall("helpers/Geohash","[[D","decode",x[['code']])
  location <- sapply(location, .jevalArray)
  data.frame(code=x[['code']], number=x[['number']], lat=location[3, 1],lnt=location[3, 2])
  }))
lbsData$number <- as.integer(lbsData$number)
### plot map
china <- get_map(location='China',maptype='roadmap',zoom=4)
nanjing <- get_map(location='Nanjing',maptype='roadmap',zoom=12)
beijing <- get_map(location='Beijing',maptype='roadmap',zoom=11)
shanghai <- get_map(location='Shanghai',maptype='roadmap',zoom=11)
guangzhou <- get_map(location='Guangzhou',maptype='roadmap',zoom=11)

ggmap(china) + 
  geom_point(data=lbsData, aes(x=lnt, y=lat,colour=number,size=number)) + 
  scale_colour_gradient(limits=c(min(lbsData$number), max(lbsData$number)),low="blue", high="red") +
  scale_size(range = c(2, 6)) +
  ggtitle('中国')

ggsave('e:/r/china.png',height=12,width=12,dpi=100)

ggmap(nanjing) + 
  geom_point(data=lbsData, aes(x=lnt, y=lat,colour=number,size=number)) + 
  scale_colour_gradient(limits=c(min(lbsData$number), max(lbsData$number)),low="blue", high="red") +
  scale_size(range = c(4, 10)) +
  ggtitle('南京')

ggsave('e:/r/nanjing.png', height=12,width=12,dpi=100)

ggmap(beijing) + 
  geom_point(data=lbsData, aes(x=lnt, y=lat,colour=number,size=number)) + 
  scale_colour_gradient(limits=c(min(lbsData$number), max(lbsData$number)),low="blue", high="red") +
  scale_size(range = c(4, 10)) +
  ggtitle('北京')
ggsave('e:/r/beijing.png',height=12,width=12,dpi=100)

ggmap(shanghai) + 
  geom_point(data=lbsData, aes(x=lnt, y=lat,colour=number,size=number)) + 
  scale_colour_gradient(limits=c(min(lbsData$number), max(lbsData$number)),low="blue", high="red") +
  scale_size(range = c(4, 10)) +
  ggtitle('上海')
ggsave('e:/r/shanghai.png',height=12,width=12,dpi=100)

ggmap(guangzhou) + 
  geom_point(data=lbsData, aes(x=lnt, y=lat,colour=number,size=number)) + 
  scale_colour_gradient(limits=c(min(lbsData$number), max(lbsData$number)),low="blue", high="red") +
  scale_size(range = c(4, 10)) + 
  ggtitle('广州')

ggsave('e:/r/guangzhou.png',height=12,width=12,dpi=100)
