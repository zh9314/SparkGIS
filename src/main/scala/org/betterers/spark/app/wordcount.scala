package org.betterers.spark.app

import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

/*
 * The command to execute this program on Spark is:
 * /root/spark/bin/spark-submit \
 * 							--class org.betterers.spark.app.SparkWordCount \
 * 							--conf "spark.eventLog.enabled=true" \
 *               --conf "spark.eventLog.dir=file:///tmp/spark-events" \
 *               --master yarn \
 *               /root/SparkGIS/target/spark-gis-0.3.0-jar-with-dependencies.jar hdfs:///Shakespeare_20.txt 0  hdfs:///output 
 */

object SparkWordCount {
  def main(args: Array[String]) {
    // create Spark context with Spark configuration
    val sc = new SparkContext(new SparkConf().setAppName("Spark Count").setMaster("yarn"))

    // get threshold
    val threshold = args(1).toInt

    // read in text file and split each document into words
    val tokenized = sc.textFile(args(0)).flatMap(_.split(" "))

    // count the occurrence of each word
    val wordCounts = tokenized.map((_, 1)).reduceByKey(_ + _)

    // filter out words with fewer than threshold occurrences
    val filtered = wordCounts.filter(_._2 >= threshold)
    
    wordCounts.saveAsTextFile(args(2))

    // count characters
    val charCounts = filtered.flatMap(_._1.toCharArray).map((_, 1)).reduceByKey(_ + _)

    System.out.println(charCounts.collect().mkString(", "))
  }
}