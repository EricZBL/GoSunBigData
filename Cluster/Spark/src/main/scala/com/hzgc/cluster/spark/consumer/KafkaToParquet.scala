package com.hzgc.cluster.spark.consumer

import java.sql.Timestamp
import java.util.Properties

import com.google.common.base.Stopwatch
import com.hzgc.cluster.spark.util.{FaceObjectUtil, PropertiesUtil}
import com.hzgc.common.table.dynrepo.DynamicTable
import kafka.common.TopicAndPartition
import kafka.message.MessageAndMetadata
import kafka.serializer.StringDecoder
import kafka.utils.ZkUtils
import org.I0Itec.zkclient.ZkClient
import org.apache.log4j.Logger
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.streaming.dstream.InputDStream
import org.apache.spark.streaming.kafka.{HasOffsetRanges, KafkaUtils}
import org.apache.spark.streaming.{Duration, Durations, StreamingContext}
object KafkaToParquet {
  val LOG: Logger = Logger.getLogger(KafkaToParquet.getClass)
  val properties: Properties = PropertiesUtil.getProperties
  case class Picture(ftpurl: String, //图片搜索地址
                     //feature：图片特征值 ipcid：设备id timeslot：时间段
                     feature: Array[Float], ipcid: String, timeslot: Int,
                     //timestamp:时间戳 pictype：图片类型 date：时间
                     exacttime: Timestamp, date: String,
                     //人脸属性：眼镜、性别、头发颜色
                     eyeglasses: Int, gender: Int, haircolor: Int,
                     //人脸属性：发型、帽子、胡子、领带
                     hairstyle: Int, hat: Int, huzi: Int, tie: Int,
                     //清晰度评价
                     sharpness: Int
                    )
  def getItem(parameter: String, properties: Properties): String = {
    val item = properties.getProperty(parameter)
    if (null != item) {
      return item
    } else {
      println("Please check the parameter " + parameter + " is correct!!!")
      System.exit(1)
    }
    null
  }
  def main(args: Array[String]): Unit = {
    val appname: String = getItem("job.faceObjectConsumer.appName", properties)
    val brokers: String = getItem("job.faceObjectConsumer.broker.list", properties)
    val kafkaGroupId: String = getItem("job.faceObjectConsumer.group.id", properties)
    val topics = Set(getItem("job.faceObjectConsumer.topic.name", properties))
    val esHost = properties.getProperty("es.hosts")
    val esPort = properties.getProperty("es.web.port")
    val spark = SparkSession.builder().config("es.nodes", esHost).config("es.port", esPort)
      .appName(appname).getOrCreate()
    val kafkaParams = Map(
      "metadata.broker.list" -> brokers,
      "group.id" -> kafkaGroupId
    )
    val ssc = setupSsc(topics, kafkaParams, spark)
    ssc.start()
    ssc.awaitTermination()
  }
  private def setupSsc(topics: Set[String], kafkaParams: Map[String, String]
                       , spark: SparkSession)(): StreamingContext = {
    val timeInterval: Duration = Durations.seconds(getItem("job.faceObjectConsumer.timeInterval", properties).toLong)
    val storeAddress: String = getItem("job.storeAddress", properties)
    val zkHosts: String = getItem("job.zkDirAndPort", properties)
    val zKPaths: String = getItem("job.kafkaToParquet.zkPaths", properties)
    val zKClient = new ZkClient(zkHosts)
    val sc = spark.sparkContext
    val ssc = new StreamingContext(sc, timeInterval)
    val messages = createCustomDirectKafkaStream(ssc, kafkaParams, zkHosts, zKPaths, topics)
    val kafkaDF = messages.map(data => (data._1, FaceObjectUtil.jsonToObject(data._2))).map(faceobject => {
      (Picture(faceobject._1, faceobject._2.getAttribute.getFeature, faceobject._2.getIpcId,
        faceobject._2.getTimeSlot.toInt, Timestamp.valueOf(faceobject._2.getTimeStamp),
        faceobject._2.getDate, faceobject._2.getAttribute.getEyeglasses, faceobject._2.getAttribute.getGender,
        faceobject._2.getAttribute.getHairColor, faceobject._2.getAttribute.getHairStyle, faceobject._2.getAttribute.getHat,
        faceobject._2.getAttribute.getHuzi, faceobject._2.getAttribute.getTie, faceobject._2.getAttribute.getSharpness), faceobject._1, faceobject._2)
    })
    kafkaDF.foreachRDD(rdd =>{
      import spark.implicits._
      rdd.map(rdd => rdd._1).repartition(1).toDF().write.mode(SaveMode.Append)
        .parquet(storeAddress)

      val rdd2 = rdd.map(record => {
        val ftpurl = record._2
        val faceObject = record._3
        val attr = faceObject.getAttribute
        val map = Map(DynamicTable.FTPURL -> ftpurl,
          DynamicTable.HAIRCOLOR -> attr.getHairColor,
          DynamicTable.EYEGLASSES -> attr.getEyeglasses,
          DynamicTable.GENDER -> attr.getGender,
          DynamicTable.HAIRSTYLE -> attr.getHairStyle,
          DynamicTable.HAT -> attr.getHat,
          DynamicTable.HUZI -> attr.getHuzi,
          DynamicTable.SHARPNESS -> attr.getSharpness,
          DynamicTable.TIE -> attr.getTie,
          DynamicTable.DATE -> faceObject.getDate,
          DynamicTable.TIMESTAMP -> faceObject.getTimeStamp,
          DynamicTable.IPCID -> faceObject.getIpcId,
          DynamicTable.TIMESLOT -> faceObject.getTimeSlot
        )
        map
      }).filter(map => {map.get(DynamicTable.FTPURL) != null})
      rdd2
    })
    import org.elasticsearch.spark.streaming._
    kafkaDF.saveToEs(DynamicTable.DYNAMIC_INDEX + "/" + DynamicTable.PERSON_INDEX_TYPE,
      Map("es.mapping.id" -> DynamicTable.FTPURL))
    messages.foreachRDD(rdd => saveOffsets(zKClient, zkHosts, zKPaths, rdd))
    ssc
  }
  private def createCustomDirectKafkaStream(ssc: StreamingContext, kafkaParams: Map[String, String], zkHosts: String
                                            , zkPath: String, topics: Set[String]): InputDStream[(String, String)] = {
    val topic = topics.last
    val zKClient = new ZkClient(zkHosts)
    val storedOffsets = readOffsets(zKClient, zkHosts, zkPath, topic)
    val kafkaStream = storedOffsets match {
      case None =>
        KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topics)
      case Some(fromOffsets) =>
        val messageHandler = (mmd: MessageAndMetadata[String, String]) => (mmd.key(), mmd.message())
        KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder
          , (String, String)](ssc, kafkaParams, fromOffsets, messageHandler)
    }
    kafkaStream
  }
  private def readOffsets(zkClient: ZkClient, zkHosts: String, zkPath: String, topic: String): Option[Map[TopicAndPartition, Long]] = {
    LOG.info("=========================== Read Offsets =============================")
    LOG.info("Reading offsets from Zookeeper")
    val stopwatch = new Stopwatch()
    val (offsetsRangesStrOpt, _) = ZkUtils.readDataMaybeNull(zkClient, zkPath)
    offsetsRangesStrOpt match {
      case Some(offsetsRangesStr) =>
        LOG.info(s"Read offset ranges: $offsetsRangesStr")
        val offsets = offsetsRangesStr.split(",")
          .map(x => x.split(":"))
          .map {
            case Array(partitionStr, offsetStr) => TopicAndPartition(topic, partitionStr.toInt) -> offsetStr.toLong
          }.toMap
        LOG.info("Done reading offsets from Zookeeper. Took " + stopwatch)
        Some(offsets)
      case None =>
        LOG.info("No offsets found in Zookeeper. Took " + stopwatch)
        LOG.info("==================================================================")
        None
    }
  }
  private def saveOffsets(zkClient: ZkClient, zkHosts: String, zkPath: String, rdd: RDD[_]): Unit = {
    LOG.info("==========================Save Offsets============================")
    LOG.info("Saving offsets to Zookeeper")
    val stopwatch = new Stopwatch()
    val offsetsRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
    offsetsRanges.foreach(offsetRange => LOG.debug(s"Using $offsetRange"))
    val offsetsRangesStr = offsetsRanges.map(offsetRange => s"${offsetRange.partition}:${offsetRange.fromOffset}")
      .mkString(",")
    LOG.info("chandan Writing offsets to Zookeeper zkClient=" + zkClient + " zkHosts=" + zkHosts + "zkPath=" + zkPath + " offsetsRangesStr:" + offsetsRangesStr)
    ZkUtils.updatePersistentPath(zkClient, zkPath, offsetsRangesStr)
    LOG.info("Done updating offsets in Zookeeper. Took " + stopwatch)
    LOG.info("==================================================================")
  }
}