library(ggplot2)
options(digits=15)
args <- commandArgs()
tsung_folder_length <- 14
tsung_folder <- args[6:length(args)]
result_path <- getwd()
getAllData <- function(data_file){
  tsung_request <- do.call(rbind, lapply(X=tsung_folder,FUN=function(x){ 
      tsung_file <- paste(x,'/data/',data_file, sep='')
      print(tsung_file)
      temp <- read.table(file=tsung_file,header=F)
      temp$code <- substr(x,nchar(x) - tsung_folder_length, nchar(x))
      temp
    }))
}
tsung_200 <- getAllData('200.txt')
tsung_request <- getAllData('request.txt')
##perfs_rate
ggplot(tsung_200,aes(x=V1, y=V2, colour=code)) +
  geom_line() +
  ggtitle('http code number (200)') +
  xlab('time') +
  ylab('response number') +
  guides(colour = guide_legend(title = 'tsung test number'))
result_jpg <- paste(result_path, '/tsung_http_code_rate.jpg', sep='')
ggsave(filename=result_jpg,width=15,height=10)
print(result_jpg)

##http_code_total
ggplot(tsung_200,aes(x=V1, y=V3, colour=code)) +
  geom_line() +
  ggtitle('http code total(200)') +
  xlab('time') +
  ylab('total response number') +
  guides(colour = guide_legend(title = 'tsung test number'))
result_jpg <- paste(result_path, '/tsung_http_code_total.jpg', sep='')
ggsave(filename=result_jpg,width=15,height=10)
print(result_jpg)
##
ggplot(data=tsung_request,aes(x=V1,y=V3,colour=code)) + 
  geom_line() + 
  ggtitle('response time') +
  xlab('time') +
  ylab('response time(ms)') +
  guides(colour = guide_legend(title = 'tsung test number'))
result_jpg <- paste(result_path, '/tsung_perfs_mean.jpg', sep='')
ggsave(filename=result_jpg,width=15,height=10)
print(result_jpg)
ggplot(data=tsung_request,aes(x=V1,y=V2,colour=code)) + 
  geom_line() +
  ggtitle('response number (10s)') +
  xlab('response time') +
  ylab('response number') +
  guides(colour = guide_legend(title = 'tsung test number'))
result_jpg <- paste(result_path, '/tsung_perfs_rate.jpg', sep='')
ggsave(filename=result_jpg,width=15,height=10)
print(result_jpg)