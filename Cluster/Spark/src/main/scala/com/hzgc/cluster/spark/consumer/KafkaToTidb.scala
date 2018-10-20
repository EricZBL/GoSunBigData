package com.hzgc.cluster.spark.consumer

import java.sql.{DriverManager, ResultSet}
import java.text.SimpleDateFormat
import java.util.{Date, Properties}

import com.hzgc.cluster.spark.util.PropertiesUtil
import com.hzgc.common.service.imsi.ImsiInfo
import com.hzgc.common.util.json.JacksonUtil
import kafka.serializer.StringDecoder
import org.apache.log4j.Logger
import org.apache.spark.SparkConf
import org.apache.spark.streaming.dstream.{DStream, InputDStream}
import org.apache.spark.streaming.kafka.KafkaUtils
import org.apache.spark.streaming.{Seconds, StreamingContext}

object KafkaToTidb {
  val log: Logger = Logger.getLogger(KafkaToParquet.getClass)
  def main(args: Array[String]): Unit = {
    val properties:Properties = PropertiesUtil.getProperties
    val jdbcIp = properties.getProperty("job.kafkaToTidb.jdbc.ip")
    val driver = properties.getProperty("job.kafkaToTidb.driver")
    val appName = properties.getProperty("job.kafkaToTidb.appName")
    val checpoint = properties.getProperty("job.kafkaToTidb.checkPoint")
    val zookeeper = properties.getProperty("job.kafkaToTidb.zookeeper")
    val kafka = properties.getProperty("job.kafkaToTidb.kafka")
    val gourpId = properties.getProperty("job.kafkaToTidb.group.id")
    val timeOut = properties.getProperty("job.kafkaToTidb.timeout")
    val topic = properties.getProperty("job.kafkaToTidb.topic")
    val jdbc = "jdbc:mysql://" + jdbcIp + ":4000/people?user=root&password="
    classOf[com.mysql.jdbc.Driver]
    Class.forName(driver)

    val conf = new SparkConf().setAppName(appName)
    val ssc: StreamingContext = new StreamingContext(conf, Seconds(5))
    ssc.checkpoint(checpoint)
    val kafkaParam = Map[String, String](
      "zookeeper.connect" -> zookeeper,
      "metadata.broker.list" -> kafka,
      "group.id" -> gourpId,
      "zookeeper.connection.timeout.ms" -> timeOut
    )
    val topicSet = Set(topic)
    val directKafka: InputDStream[(String, String)] = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParam, topicSet)
    val windowed: DStream[(String, Int)] = directKafka.map(tuple2 => {
      val imsiObject = JacksonUtil.toObject(tuple2._2, classOf[ImsiInfo])
      val imsi = imsiObject.getImsi
      (imsi,1)
    })
    //second1:窗口长度，second2:滑动间隔
    val result: DStream[(String, Int)] = windowed.reduceByKeyAndWindow((a: Int, b: Int) => a + b, Seconds(3600), Seconds(60))
    result.filter(x=> x._2 >= 3).foreachRDD(it => {
      it.foreachPartition(datas => {
        val conn = DriverManager.getConnection(jdbc)
        val prep = conn.prepareStatement("INSERT INTO t_imsi_filter (imsi,count,currenttime) VALUES (?, ?, ?) ")
        val preps = conn.prepareStatement("SELECT imsi FROM t_imsi_filter WHERE imsi = ? AND currenttime = ?")
        datas.foreach(f = data => {
          val imsi: String = data._1
          val num = data._2
          val sdf = new SimpleDateFormat("yyyyMMdd")
          val nowTime = new Date().getTime
          val time = sdf.format(nowTime)
          preps.setString(1, imsi)
          preps.setString(2, time)
          val result: ResultSet = preps.executeQuery()
          if ( !result.next()) {
            prep.setString(1, imsi)
            prep.setInt(2, num)
            prep.setString(3, time)
            prep.executeUpdate
            log.info("===========imsi=" + imsi + ", num=" + num + ", time=" + time)
          }
        })
      })
    })

    ssc.start()
    ssc.awaitTermination()
  }
}
