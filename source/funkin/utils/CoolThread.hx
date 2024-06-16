package funkin.utils;
#if sys import sys.thread.Thread; #end

class CoolThread
{
	#if sys private static var thread:Thread; #end
	private static var jobArray:Array<() -> Void> = [];
	public static var lastRunCompleted:Bool = false;
	public static var isCurrentlyRunning:Bool = false;

	public function new()
	{
		#if sys
		thread = Thread.createWithEventLoop(() ->
		{
			Thread.current().events.promise();
		});
		#end
	}

	public function addJob(func:() -> Void)
	{
		if (!jobArray.contains(func))
			jobArray.push(func);
	}

	public function addJobAndRun(func:() -> Void)
	{
		addJob(func);
		run();
	}

	public function clearAllJobs()
	{
		jobArray = [];
	}

	public function run()
	{
		#if sys
		thread.events.run(() ->
		{
		#end
			for (job in jobArray)
			{
				job();
			}
		#if sys	
		});
		#end
	}
}
