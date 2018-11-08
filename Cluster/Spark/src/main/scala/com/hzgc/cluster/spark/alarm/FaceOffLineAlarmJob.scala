//package com.hzgc.cluster.spark.alarm
//
//import java.text.SimpleDateFormat
//
//import com.google.gson.Gson
//import com.hzgc.cluster.spark.util.PropertiesUtil
//import com.hzgc.common.service.facestarepo.alarm.StarepoServiceUtil
//import com.hzgc.common.service.facestarepo.alarm.StarepoServiceUtil.ObjectInfo
//import org.apache.spark.{SparkConf, SparkContext}
//import org.elasticsearch.spark.rdd.EsSpark
//
//
///**
//  * 从Phoenix获取离线告警数据存放入ES的off_alarm类型中
//  */
//object FaceOffLineAlarmJob {
//
//  case class OffAlarmJson(alarm_time:String, alarm_type:Int, check_use:String, confirm:Int, flag:Int,
//                          last_appearance_time:String, object_type:String, similarity:String, static_id:String, suggestion:String)
//
//  def main(args: Array[String]): Unit = {
//
//    val properties = PropertiesUtil.getProperties
//    val appName = properties.getProperty("job.offLine.appName")
//    val jdbcPhoenixUrl = properties.getProperty("job.offLine.jdbcUrl")
//    val esNodes = properties.getProperty("job.offLine.esNodes")
//    val esPort = properties.getProperty("job.offLine.esPort")
//    //允许离线告警时长，单位为毫秒(ms)
//    val updateTimeInterval = properties.getProperty("job.offLine.timeInterval").toInt
//    val conf = new SparkConf().setAppName(appName)
//      .set("es.index.auto.create","true")
//      .set("es.nodes",esNodes)
//      .set("es.port",esPort)
//
//    val sc = new SparkContext(conf)
//
//    val starepoServiceUtil = new StarepoServiceUtil()
//
//    import scala.collection.JavaConverters._
//    val phoenixData: List[ObjectInfo] = starepoServiceUtil.getOfflineAlarm(jdbcPhoenixUrl, updateTimeInterval).asScala.toList
//
//    val rddData = sc.parallelize(phoenixData).map(object2json(_))
//
//    EsSpark.saveJsonToEs(rddData, "alarm1/off_alarm")
//
//    sc.stop()
//  }
//
//  def object2json(data:ObjectInfo): String = {
//    val alarm_time: String = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(System.currentTimeMillis())
//    val offAlarmJson = OffAlarmJson(alarm_time,102,"",1,0,data.getUpdatetime.toString,data.getPkey,"",data.getId,"")
//    val gson = new Gson()
//    val json = gson.toJson(offAlarmJson)
//    json
//  }
//
//}
