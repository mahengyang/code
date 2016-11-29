# -*- coding: utf-8 -*-
import string,gzip,json,sys,os,re,threading
import multiprocessing
from multiprocessing import Process,Queue,Lock,Manager,Pool
from Queue import Empty
import multiprocessing.pool
import sys 
reload(sys) 
sys.setdefaultencoding('utf-8')

test = len(sys.argv)
# 字符串转为数字，float类型
def time2float(t) :
  if t == '-':
    tmp = 0
  else :
    tmp = float(t)      
  return tmp

logfiles = []

destDir = sys.argv[1]
listfile = os.listdir(destDir)
# 遍历日志目录,获取每一个文件名字
for path in listfile:
  path = destDir + path
  logfiles.append(path)

def parseLine (line, lock, urlQueue, clientIpQueue, upstreamIpQueue) :
  line = re.sub(r'\\x','',line)
  meta = json.loads(line)["meta"]
  # 提取所需字段
  clientIp = meta["clientIp"]
  request = meta["request"].replace(" HTTP/1.1","").replace("POST ","").replace("GET ","").replace("HEAD","").replace(" HTTP/1.0","")
  request = re.sub(r'\?.*$',"",request)
  # 去掉静态资源请求
  if request.endswith('.js') or \
     request.endswith('.map') or \
     request.endswith('.css') or \
     request.endswith('.png') or \
     request.endswith('.jpg') or \
     request.endswith('.woff2') or \
     request.endswith('.gif') :
    return
  status = meta["status"]
  reqTime = time2float(meta["reqTime"])
  upRespTime = time2float(meta["upRespTime"])
  upstreamIp = meta["upstreamIp"]
  upstreamIp = upstreamIp.replace("172.16.","").replace(":8080","")
  urlQueue.put((request, status, reqTime, upRespTime, upstreamIp))
  clientIpQueue.put((clientIp,upstreamIp,request))
  upstreamIpQueue.put(upstreamIp)
 
def parse (path, lock, urlQueue, clientIpQueue, upstreamIpQueue) :
  fileContent = gzip.open(path, 'rt')
  a = 1
  for line in fileContent:
    a = a + 1
    if test == 3:
      if a > int(sys.argv[2]):
        return 1 
    parseLine(line, lock, urlQueue, clientIpQueue, upstreamIpQueue)

def readUrlQueue (urlQueue, urlsResultQueue, lock) :
  urls = {}
  while True:
    try:
      request,status,reqTime,upRespTime,upstreamIp = urlQueue.get(True, 2)
      # 存入字典中   
      urlCount,urlDealCount,urlReqTime,urlUpRespTime,urlStatus,urlUpstreamIp = urls.get(request,(0,0,reqTime,upRespTime,{},{}))
      if upstreamIp != '-' :
        urlDealCount = urlDealCount + 1
      # 统计每个url的响应码频次
      urlStatus[status] = urlStatus.get(status,0) + 1
      # 统计每个url落到那个后台应用服务上
      urlUpstreamIp[upstreamIp] = urlUpstreamIp.get(upstreamIp, 0) + 1
      urls[request] = (urlCount + 1, urlDealCount, urlReqTime + reqTime, urlUpRespTime + upRespTime, urlStatus, urlUpstreamIp)
    except Empty :
      break
  urlsResultQueue.put(urls)

def readClientIpQueue (clientIpQueue, clientIpsResultQueue, lock) :
  clientIps = {}
  while True:
    try:
      clientIp,upstreamIp,request = clientIpQueue.get(True, 2)
      # 总数，被处理数，请求的api和次数
      totalCount,dealCount,requestCountMap = clientIps.get(clientIp,(0,0,{}))
      totalCount = totalCount + 1
      if upstreamIp != '-' :
        dealCount = dealCount + 1
      requestCountMap[request] = requestCountMap.get(request,0) + 1
      clientIps[clientIp] = (totalCount, dealCount, requestCountMap)
    except Empty :
      break
  # 把最终结果放入队列，返回给主线程
  clientIpsResultQueue.put(clientIps)

def readUpstreamIpQueue (upstreamIpQueue, upstreamIpsResultQueue, lock) :
  upstreamIps = {}
  while True:
    try:
      upstreamIp = upstreamIpQueue.get(True, 2)
      upstreamIps[upstreamIp] = upstreamIps.get(upstreamIp,1) + 1
    except Empty :
      break
  # 把最终结果放入队列，返回给主线程
  upstreamIpsResultQueue.put(upstreamIps)

# 每个文件一个进程
threads = []
manager = Manager()
lock = manager.Lock()
urlsResultQueue = manager.Queue(1)
clientIpsResultQueue = manager.Queue(1)
upstreamIpsResultQueue = manager.Queue(1)

urlQueue = manager.Queue(500)
clientIpQueue = manager.Queue(500)
upstreamIpQueue = manager.Queue(500)
pool = Pool(24)
for f in logfiles :
  pool.apply_async(parse, (f, lock, urlQueue, clientIpQueue, upstreamIpQueue))

urlP = Process(target=readUrlQueue, args=(urlQueue, urlsResultQueue, lock))
urlP.start()
threads.append(urlP)
clientIpP = Process(target=readClientIpQueue, args=(clientIpQueue, clientIpsResultQueue, lock))
clientIpP.start()
threads.append(clientIpP)
upstreamIpP = Process(target=readUpstreamIpQueue, args=(upstreamIpQueue, upstreamIpsResultQueue, lock))
upstreamIpP.start()
threads.append(upstreamIpP)
for t in threads : 
  t.join()

urls = urlsResultQueue.get(False, 1)
clientIps = clientIpsResultQueue.get(False, 1)
upstreamIps = upstreamIpsResultQueue.get(False, 1)

finalUrls = sorted(urls.iteritems(), key=lambda d:d[1][0], reverse = True)
finalClientIps = sorted(clientIps.iteritems(), key=lambda d:d[1][0], reverse = True)
finalUpstreamIps = sorted(upstreamIps.iteritems(), key=lambda d:d[1], reverse = True)

# 打印最终的统计数据
print "upstreamIp","count"
for key,value in finalUpstreamIps:
  print key, value
print
print "total-count", "deal-count", "status", "upstreamIp", "reqTime", "upRespTime","url"
for key,value in finalUrls :
  urlCount,urlDealCount,urlReqTime, urlUpRespTime, status,upstreamIp = value 
  print urlCount,urlDealCount,str.join(',', map(lambda x: '{0}:{1}'.format(x,status[x]),status)), str.join(',', map(lambda x: '{0}:{1}'.format(x,upstreamIp[x]),upstreamIp)), round(urlReqTime / urlCount,3), round(urlUpRespTime / urlCount,3), key
print 
print "client-ip","total-count","deal-count","request-count"
for key,value in finalClientIps:
  totalCount,dealCount,requestCountMap = value
  requestCountMap = sorted(requestCountMap.iteritems(), key=lambda d:d[1], reverse = True)
  if totalCount > 50 :
    print key,totalCount,dealCount,str.join(",", map(lambda x: '{0}:{1}'.format(x[0], x[1]), requestCountMap))

