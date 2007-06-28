import flash.external.ExternalInterface;import org.osflash.thunderbolt.io.Console;import org.osflash.thunderbolt.data.Parser;import org.osflash.thunderbolt.data.StringyfiedObject;import org.osflash.thunderbolt.profiling.Profiler;import org.osflash.thunderbolt.profiling.ProfileHandle;import org.osflash.thunderbolt.Logger;/** * The Commandline class enables several debugging features  * WHILE the movie is running. You can inspect an element or * set it's attributes. *  * @author Martin Kleppe <kleppe@gmail.com> */class org.osflash.thunderbolt.io.Commandline {		private static var initialized:Boolean;		/**	 * Initializes the Commandline callbacks.	 */	public static function initialize():Void{		if (!Commandline.initialized){						// associate external calls			ExternalInterface.addCallback("start", Commandline, Commandline.start);			ExternalInterface.addCallback("stop", Commandline, Commandline.stop);			ExternalInterface.addCallback("inspect", Commandline, Commandline.inspect);			ExternalInterface.addCallback("set", Commandline, Commandline.set);			ExternalInterface.addCallback("run", Commandline, Commandline.run);			ExternalInterface.addCallback("profile", Commandline, Commandline.profile);			ExternalInterface.addCallback("profileEnd", Commandline, Commandline.profileEnd);			Commandline.initialized = true;		}		}	/**	 * Start the logger. Messages will be traced to the console.	 * Usage: ThunderBolt.stop();	 */  	private static function start():Void{				Logger.stopped = false;		}		/**	 * Mutes the logger. Messages will no longer traced to the console.	 * Usage: ThunderBolt.stop();	 */  	private static function stop():Void{				Logger.stopped = true;		}				/**	 * Inspects an object.	 * Usage: ThunderBolt.inpect(target);	 */  	private static function inspect(target:String):Void{				var out:Object = _global[target] || _root[target] || eval(target);		Console.log(new StringyfiedObject(out, 10));		}	/**	 * Evaluates an expression.	 * Usage: ThunderBolt.run(expression);	 */  		private static function run(expression:String):Void{				var parts:Array = expression.split("(");				var info:Object = {						method: parts[0],			arguments: parts[1]		};			if (info.arguments){						var closingBrackets:Number = info.arguments.lastIndexOf(")");			info.arguments = info.arguments.substring(0, closingBrackets); 			}				var returnValue = eval(info.method)(info.arguments);				Console.log(info.method + "(" + info.arguments + "); //",			new StringyfiedObject(returnValue, 255, returnValue.toString())		);	}		/**	 * Sets an objects attribute.	 * Usage: ThunderBolt.set(target, value);	 */  		private static function set(target:String, value:String):Void{					var parts = target.split(".");				var property = parts.pop();		target = parts.join(".");		var object:Object = _global[target] || _root[target] || eval(target);		object[property] = value;				Console.log(new StringyfiedObject(object, 10));	}		private static function profile(target){				var out:Object = _global[target] || _root[target] || eval(target);				var cache:Array = Profiler.start(out);		Console.log("Monitoring " + cache.length + " methods...");	}		private static function profileEnd(target){				var log:Array = Profiler.stop();				if (!log) {					return;			}				Console.group("Profiling results (" + log.length + " methods were monitored):");						for (var i:Number=0; i<log.length; i++) {					var profile:ProfileHandle = log[i];						Console.log(new StringyfiedObject(				{					count: 		profile.executionCount,					min:		profile.minTime, 					max:		profile.maxTime,					total:		profile.totalTime, 					average:	profile.averageTime									}, 2, profile.methodName + ": ")			);		};				Console.groupEnd();	}			}