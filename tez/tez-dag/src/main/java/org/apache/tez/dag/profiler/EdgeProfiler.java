package org.apache.tez.dag.profiler;

// keep track for every edge
// from; to; data movement type
public class EdgeProfiler {

	public String from;
	public String to;
	public String data_movement;
	
	public EdgeProfiler(String _from, String _to, String _data_movement) {
		from = _from;
		to   = _to;
		data_movement = _data_movement;
	}
}
