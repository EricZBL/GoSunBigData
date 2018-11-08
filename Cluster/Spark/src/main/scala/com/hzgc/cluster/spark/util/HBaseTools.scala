//package com.hzgc.cluster.spark.util
//
//import org.apache.hadoop.hbase.HBaseConfiguration
//import org.apache.hadoop.hbase.client.{Get, Put, Result, Scan}
//import org.apache.hadoop.hbase.io.ImmutableBytesWritable
//import org.apache.hadoop.hbase.mapreduce.TableInputFormat
//import org.apache.hadoop.hbase.protobuf.ProtobufUtil
//import org.apache.hadoop.hbase.util.{Base64, Bytes}
//import org.apache.spark.SparkContext
//import org.apache.spark.rdd.RDD
//
//object HBaseTools {
//
//  val properties = PropertiesUtil.getProperties
//  val zkQuorum = properties.getProperty("hbase.zookeeper.quorum")
//  val zkPort = properties.getProperty("hbase.zookeeper.clientPort")
//
//  val hbaseConfig = HBaseConfiguration.create()
//  hbaseConfig.set("hbase.zookeeper.quorum", zkQuorum)
//  hbaseConfig.set("hbase.zookeeper.property.clientPort", zkPort)
//
//  def scan2string(scan:Scan):String = {
//    val proto = ProtobufUtil.toScan(scan)
//    val result = Base64.encodeBytes(proto.toByteArray)
//    result
//  }
//
//  def getData(rowKey:String, cf:String=null, qf:String=null): Get = {
//    val get = new Get(Bytes.toBytes(rowKey))
//    if((qf != null) && (cf != null))
//      get.addColumn(Bytes.toBytes(cf), Bytes.toBytes(qf))
//    get
//  }
//
//  def putData(rowKey:String, cf:Array[Byte], qf:Array[Byte], value:String) : Put = {
//    val put = new Put(Bytes.toBytes(rowKey))
//    put.addColumn(cf, qf, Bytes.toBytes(value))
//    put
//  }
//
//  def scan2rdd(sc:SparkContext, tableName:String, startRowKey:String, stopRowKey:String): RDD[(ImmutableBytesWritable, Result)] = {
//    val scan = new Scan()
//    scan.setStartRow(Bytes.toBytes(startRowKey))
//    scan.setStopRow(Bytes.toBytes(stopRowKey))
//    hbaseConfig.set(TableInputFormat.INPUT_TABLE, tableName)
//    hbaseConfig.set(TableInputFormat.SCAN, scan2string(scan))
//    val rdd = sc.newAPIHadoopRDD(hbaseConfig, classOf[TableInputFormat], classOf[ImmutableBytesWritable], classOf[Result])
//    rdd
//  }
//
//}
