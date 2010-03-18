/+ Copyright (c) 2010 by Álvaro Castro-Castilla, All Rights Reserved.         +/
/+ Licensed under the GPLv3 license, see LICENSE file for full description.   +/

module monitor.status;

private {
	import std.stdio;
	import std.conv;
	import std.c.time;
	import core.sys.posix.unistd;
}

class Status {

	private {
		time_t now;
		time_t before;
		tm* now_timeinfo;
		tm* working_timeinfo;
	}

	@property {
		// working times
		int w_sec;
		int w_min;
		int w_hour;
		time_t working;
	}

	void restoreFromFile(in string file_name) {
		auto f = File(file_name, "r");
		time_t saved;

		now = time(null);
		now_timeinfo = localtime(&now);

		auto working_saved_s = f.readln();
		auto saving_saved_s = f.readln();
		auto working_saved = parse!time_t(working_saved_s);
		auto saving_time = parse!time_t(saving_saved_s);

		auto comp = now - saving_time;
		auto comp_ti = localtime(&comp);

		writeln("");
		auto working_saved_ti = localtime(&working_saved);
		writeln("La última vez, el contador de curro estaba a "
				~ to!string(working_saved_ti.tm_hour-1) ~ "h. "
				~ to!string(working_saved_ti.tm_min) ~ "m. "
				~ to!string(working_saved_ti.tm_sec) ~ "s. " );
		writeln("");

		// We are in a new day if:
		if ( ((working_saved_ti.tm_hour > 2 && working_saved_ti.tm_hour < 8) // If was saved at night and slept 1 hour at least
			   && (comp >= 3600))
			 || (comp >= 36000) ) { // or enough time has passed (10h.)

			if ( working_saved_ti.tm_hour > 6 ) {
				now_timeinfo = localtime(&now);
				if ( now_timeinfo.tm_hour < 11 ) {
					writeln("Parece que la última vez curraste suficiente, pero hoy vas, vienes tarde y la jodes");
				} else {
					writeln("Parece que la última vez curraste suficiente y vienes hoy prontito. Sigue así y mejora");
				}
			} else {
				now_timeinfo = localtime(&now);
				if ( now_timeinfo.tm_hour < 11 ) {
					writeln("No curraste ni 6 míseras horas la última vez, pero al menos vienes pronto. Vengo coño, dale fuerte.");
				} else {
					writeln("No curraste ni 6 míseras horas la última vez y encima vienes tarde. Patético. Replantéate tu vida.");
				}
			}
			createFromScratch();
			writeln("");
			writeln("");
			sleep(8);
		} else {
			writeln("Continuemos donde lo dejamos, espero que no hayas estado jugando al Coloduti!!");
			working = working_saved;
			working_timeinfo = localtime(&working);
			w_sec = working_timeinfo.tm_sec;
			w_min = working_timeinfo.tm_min;
			w_hour = working_timeinfo.tm_hour - 1;
			writeln("");
			writeln("");
			sleep(2);
		}
	}

	void createFromScratch() {
		w_sec = 0;
		w_min = 0;
		w_hour = 0;
	}

	void saveToFile(in string file_name) {
		auto f = File(file_name, "w");
		f.writeln(working);
		f.writeln(now);
	}

	void start() {
		now = time(null);
		now_timeinfo = localtime(&now);
		before = now;
	}

	void update(bool beenWorking) {
		if (beenWorking) {
			before = now;
			now = time(null);
			working += now - before;
		}
		working_timeinfo = localtime(&working);
		w_sec = working_timeinfo.tm_sec;
		w_min = working_timeinfo.tm_min;
		w_hour = working_timeinfo.tm_hour - 1;
	}

	void stop() {
		now = time(null);
	}
}
