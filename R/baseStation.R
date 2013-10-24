library(ggmap)
library(mapproj)

baseStation = read.csv(file='e:/r/data/baseStation.data',sep=' ')
names(baseStation) = c('lnt','lat')
### plot map
china <- get_map(location='China',maptype='roadmap',zoom=4)
world2 <- get_map(location='China',maptype='roadmap',zoom=2)
nanjing <- get_map(location='Nanjing',maptype='roadmap',zoom=12)
beijing <- get_map(location='Beijing',maptype='roadmap',zoom=11)
shanghai <- get_map(location='Shanghai',maptype='roadmap',zoom=11)
guangzhou <- get_map(location='Guangzhou',maptype='roadmap',zoom=11)

ggmap(world2) + 
  geom_point(data=baseStation, aes(x=lnt, y=lat)) + 
  ggtitle('world2')

ggsave('e:/r/img/world2.png',height=12,width=12,dpi=100)

ggmap(china) + 
  geom_point(data=baseStation, aes(x=lnt, y=lat)) + 
  ggtitle('中国')

ggsave('e:/r/img/china.png',height=12,width=12,dpi=100)

ggmap(nanjing) + 
  geom_point(data=baseStation, aes(x=lnt, y=lat)) + 
  ggtitle('南京')

ggsave('e:/r/img/nanjing.png', height=12,width=12,dpi=100)

ggmap(beijing) + 
  geom_point(data=baseStation, aes(x=lnt, y=lat)) + 
  ggtitle('北京')
ggsave('e:/r/img/beijing.png',height=12,width=12,dpi=100)

ggmap(shanghai) + 
  geom_point(data=baseStation, aes(x=lnt, y=lat)) + 
  ggtitle('上海')
ggsave('e:/r/img/shanghai.png',height=12,width=12,dpi=100)

ggmap(guangzhou) + 
  geom_point(data=baseStation, aes(x=lnt, y=lat)) + 
  ggtitle('广州')

ggsave('e:/r/img/guangzhou.png',height=12,width=12,dpi=100)
