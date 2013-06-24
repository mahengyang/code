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

xlab <- xlab('time')
guides <- guides(colour = guide_legend(title = 'tsung test number'))
geom_type <- geom_line()
common <- list(xlab,guides,geom_type)

save_result <- function(result_name) {
  result_jpg <- paste(result_path, '/tsung_',result_name, '.jpg', sep='')
  ggsave(filename=result_jpg,width=15,height=10)
  print(result_jpg)
}
ggplot(tsung_200,aes(x=V1, y=V2, colour=code)) +
  ggtitle('http code number (200)') +
  ylab('response number') +
  common
save_result('http_code_rate')

ggplot(tsung_200,aes(x=V1, y=V3, colour=code)) +
  ggtitle('http code total(200)') +
  ylab('total response number') +
  common
save_result('http_code_total')

ggplot(data=tsung_request,aes(x=V1,y=V3,colour=code)) + 
  ggtitle('response time') +
  ylab('response time(ms)') +
  common
save_result('perfs_mean')

ggplot(data=tsung_request,aes(x=V1,y=V2,colour=code)) + 
  ggtitle('response number (10s)') +
  ylab('response number') +
  common
save_result('perfs_rate')