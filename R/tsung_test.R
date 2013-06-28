## example: 
## Rscript.exe compare_tsung_result.R  20130621-1222 20130621-1420
## or
## Rscript.exe compare_tsung_result.R 200.txt 2 20130621-1222 20130621-1420
## 200.txt means tsung data file, 2 means second column of 200.txt
library('ggplot2')
library('RColorBrewer')

options(digits=15)
args <- commandArgs()
tsung_folder_length <- 14
result_path <- getwd()
getAllData <- function(data_file, lab_y){
  tsung_request <- do.call(rbind, lapply(X=tsung_folder,FUN=function(x){ 
      tsung_file <- paste(x,'/data/',data_file, sep='')
      print(tsung_file)
      temp <- read.table(file=tsung_file,header=F)
      temp$code <- substr(x,nchar(x) - tsung_folder_length, nchar(x))
      temp$y <- temp[, as.integer(lab_y)]
      temp
    }))
}

xlab <- xlab('time')
guides <- guides(colour = guide_legend(title = 'tsung test number'))
geom_type <- geom_line()
theme <- theme(plot.title=element_text(size=20),
  axis.line=element_line(size=0.9), 
  axis.title.x=element_text(size=15),
  axis.title.y=element_text(size=15),
  axis.text.x=element_text(size=15,angle=45,hjust=1),
  axis.text.y=element_text(size=15),
  legend.title=element_text(size=15),
  legend.text=element_text(size=12)
  )
line_width <- geom_path(size=1.5)
color <- scale_colour_brewer(palette='Set1')

common <- list(xlab,guides,geom_type,theme,line_width,color)

save_result <- function(result_name) {
  result_jpg <- paste(result_path, '/tsung_',result_name, '.jpg', sep='')
  ggsave(filename=result_jpg,width=15,height=10)
  print(result_jpg)
}

plot_tsung <- function(tsung_data_file, y){
  tsung_data <- getAllData(tsung_data_file,y)
  ggplot(tsung_data,aes(x=V1, y=y, colour=code)) +
  #tsung 200.txt column:1
  ggtitle(paste('tsung',tsung_data_file, 'column',y)) +
  ylab(paste('column', y)) +
  scale_y_continuous(breaks=seq(0,max(tsung_data$y),as.integer(max(tsung_data$y)/20))) +
  scale_x_continuous(breaks=seq(0,max(tsung_data$V1),10)) +
  common
  save_result(paste(tsung_data_file,'column',y,sep='_'))
}

if(grepl('.txt',args[6],ignore.case=T) == T){
  tsung_folder <- args[8:length(args)]
  plot_tsung(args[6],args[7])
}else{
  tsung_folder <- args[6:length(args)]
  plot_tsung('200.txt',2)
  plot_tsung('200.txt',3)
  plot_tsung('request.txt',2)
  plot_tsung('request.txt',3)
}