//Thread.sleep(180000) // wait 3 mins for resources setup

val slices = 100000
val n = math.min(100000L * slices, Int.MaxValue).toInt // avoid overflow

for (idx <- 1 to 2) {
	// start time

	val count = sc.parallelize(1 until n, slices).map { i =>
		val x = scala.math.random * 2 - 1
		val y = scala.math.random * 2 - 1
		if (x*x + y*y < 1) 1 else 0
	}.reduce(_ + _)
	println("Pi is roughly " + 4.0 * count / n)
	// end time
	
	Thread.sleep(15000)
}

//:quit
