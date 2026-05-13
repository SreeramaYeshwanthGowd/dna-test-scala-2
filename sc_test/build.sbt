
// This file is used to build the sbt project with Databricks Connect.
// This also includes the instructions on how to create the jar uploaded via databricks bundle

name := "dna-test-scala"
organization := "com.laerdal"
organizationName := "Laerdal Medical"
useCoursier := false
scalaVersion := "2.12.18"

val sparkVersion = "3.5.0"

crossPaths := false

resolvers ++= Seq(
  "GitHub Package Registry" at
    "https://maven.pkg.github.com/Laerdal-Medical/dna-dataplatform-anonymizer",
  Resolver.url(
    "typesafe",
    url("https://repo.typesafe.com/typesafe/ivy-releases/")
  )(Resolver.ivyStylePatterns)
)

credentials += Credentials(
  "GitHub Package Registry",
  "maven.pkg.github.com",
  sys.env.getOrElse("GITHUB_ACTOR", ""),
  sys.env.getOrElse("GITHUB_TOKEN", "")
)

version := "0.1.0"

libraryDependencies += "org.apache.spark" %% "spark-core" % sparkVersion % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % sparkVersion % "provided"
libraryDependencies += "org.slf4j" % "slf4j-simple" % "2.0.16"
libraryDependencies += "com.databricks" %% "databricks-dbutils-scala" % "0.1.5"
libraryDependencies += "com.audienceproject" %% "simple-arguments" % "1.0.3"
libraryDependencies += "org.yaml" % "snakeyaml" % "2.4"
libraryDependencies += "org.scalatest" %% "scalatest" % "3.2.19" % Test
// dna-dataplatform-anonymizer is provided as an unmanaged jar in lib/
// libraryDependencies += "com.laerdal" %% "dna-dataplatform-anonymizer" % "1.1.6"

assembly / assemblyOption ~= { _.withIncludeScala(false) }
assembly / assemblyExcludedJars := {
  val cp = (assembly / fullClasspath).value
  cp filter { _.data.getName.matches("scala-.*") } // remove Scala libraries
}

assembly / assemblyMergeStrategy := {
  case PathList("META-INF", _ @_*) => MergeStrategy.discard
  case "reference.conf"            => MergeStrategy.concat
  case _                           => MergeStrategy.preferProject
}

// to run with new jvm options, a fork is required otherwise it uses same options as sbt process
fork := true
javaOptions += "--add-opens=java.base/java.nio=ALL-UNNAMED"

// To ensure logs are written to System.out by default and not System.err
javaOptions += "-Dorg.slf4j.simpleLogger.logFile=System.out"

