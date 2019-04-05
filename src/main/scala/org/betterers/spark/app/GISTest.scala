package org.betterers.spark.app

import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.betterers.spark.gis.Geometry
import org.apache.spark.sql.types._
import org.apache.spark.sql.{SQLContext, Row}

import scala.collection.mutable.WrappedArray

/*
 * The command to execute this program on Spark is:
 * /root/spark/bin/spark-submit \
 * 							 --class org.betterers.spark.app.GISTest \
 * 							 --conf "spark.eventLog.enabled=true"  \
 * 							 --conf "spark.eventLog.dir=file:///tmp/spark-events" \
 *                --master yarn  \
 *                /root/SparkGIS/target/spark-gis-0.3.0-jar-with-dependencies.jar hdfs:///GISTest.txt 
 */
object GISTest {
  def main(args: Array[String]) {
   
    
    // create Spark context with Spark configuration
    val sc = new SparkContext(new SparkConf().setAppName("SparkGIS Test"))

    val sqlContext = new org.apache.spark.sql.SQLContext(sc)

    // read geojson strings from a text file or set of files from a directory
    //val geojsonStrings = sc.wholeTextFiles(args(0)).values.collect().toString()
    val featureGeoJson = sqlContext.read.json(args(0)).filter("type is not null")
    //val example = Geometry.fromGeoJson(geojsonStrings(0))
    featureGeoJson.printSchema()
    featureGeoJson.registerTempTable("featuresjson")
    featureGeoJson.show()
    
    val geos = sqlContext.sql("SELECT geometry.coordinates, geometry.type FROM featuresjson")
    geos.show()
    
    var colStr1:String = ""
    var colStr2:String = ""
    var geoGs:List[Geometry] = Nil
    geos.rdd.collect().foreach{ x => {
        //val geoTypes = Geometry.fromGeoJson(row.toString())
        x.toSeq.foreach{col => {
            if(col.isInstanceOf[String]){
              colStr1 = "\"type\":" + "\"" + col + "\"" 
              //println(colStr1)
            }else{
              val vals = col.asInstanceOf[WrappedArray[Double]].mkString("[", ",", "]")
              colStr2 = "\"coordinates\": " + vals
              //println(colStr2)
            }
          }
        }
        val geojs = "{ " + colStr1 + ", " + colStr2 +"}"
        geoGs = geoGs :+ Geometry.fromGeoJson(geojs)
      }
      
    }
    
    import org.betterers.spark.gis.GeometryOperators._
    import Geometry.ImplicitConversions._
    import Geometry.WGS84
    
    
    val l1 = Geometry.line((10.0,10.0), (20.0,20.0), (10.0,30.0))
    
    val p1 = geoGs(0)
    val p2 = geoGs(1)
    println(p1)
    println(p2)
    println(("distance: "+p1.distance(p2)))
    if((p1 <-> p2) < 50){
      println("True")
    }
    
    //System.out.println("The number of GEOs: "+geos.collect.length)

  }
}